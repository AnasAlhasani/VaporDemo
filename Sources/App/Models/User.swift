import FluentSQLite
import Vapor

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
