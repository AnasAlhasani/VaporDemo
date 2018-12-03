import Vapor

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

