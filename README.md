<p align="center">
    <img src="https://user-images.githubusercontent.com/1342803/36623515-7293b4ec-18d3-11e8-85ab-4e2f8fb38fbd.png" width="320" alt="API Template">
    <br>
    <br>
    <a href="http://docs.vapor.codes/3.0/">
        <img src="http://img.shields.io/badge/read_the-docs-2196f3.svg" alt="Documentation">
    </a>
    <a href="http://vapor.team">
        <img src="http://vapor.team/badge.svg" alt="Slack Team">
    </a>
    <a href="LICENSE">
        <img src="http://img.shields.io/badge/license-MIT-brightgreen.svg" alt="MIT License">
    </a>
    <a href="https://circleci.com/gh/vapor/api-template">
        <img src="https://circleci.com/gh/vapor/api-template.svg?style=shield" alt="Continuous Integration">
    </a>
    <a href="https://swift.org">
        <img src="http://img.shields.io/badge/swift-4.1-brightgreen.svg" alt="Swift 4.1">
    </a>
</center>

* `Model` 

```swift
final class User: Codable {
    var id: UUID?
    var name: String
    var age: Int
    
    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
}

extension User: SQLiteUUIDModel { }
extension User: Content { }
extension User: Migration { }
extension User: Parameter { }
```

* `Controller` 

```swift
struct UsersController: RouteCollection {
    
    func boot(router: Router) throws {
        let usersRoute = router.grouped("api", "users")
        usersRoute.get(User.parameter, use: fetch)
        usersRoute.get(use: fetchAll)
        usersRoute.post(use: create)
        usersRoute.delete(User.parameter, use: delete)
        usersRoute.put(User.parameter, use: update)
    }
    
    private func fetch(_ request: Request) throws -> Future<User> {
        return try request.parameters.next(User.self)
    }
    
    private func fetchAll(_ request: Request) throws -> Future<[User]> {
        return User.query(on: request).all()
    }
    
    private func create(_ request: Request) throws -> Future<User> {
        return try request.content.decode(User.self).flatMap {
            $0.save(on: request)
        }
    }
    
    private func delete(_ request: Request) throws -> Future<HTTPStatus> {
        return try request.parameters.next(User.self).flatMap(to: HTTPStatus.self, {
            $0.delete(on: request).transform(to: .noContent)
        })
    }
    
    private func update(_ request: Request) throws -> Future<User> {
        return flatMap(to: User.self, try request.parameters.next(User.self), try request.content.decode(User.self), { (user, updatedUser) in
            user.name = updatedUser.name
            user.age = updatedUser.age
            return user.save(on: request)
        })
    }
}
```
