import Foundation

class TodoItem: Codable {
    var id: String 
    var title: String
    var completed: Bool
    
    init(title: String, completed: Bool = false) {
        self.id = UUID().uuidString
        self.title = title
        self.completed = completed
    }
}