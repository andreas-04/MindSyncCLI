import Foundation

class TodoItem: Codable {
    var id: UUID 
    var title: String
    var completed: Bool
    
    init(title: String, completed: Bool = false) {
        self.id = UUID() // Generate a new UUID for each TodoItem
        self.title = title
        self.completed = completed
    }
}