import Foundation

class TodoApp {
    private let fileName = "todos.json"
    private var nextId = 0

    init() {
        // Initialize the first time
        if let _ = loadTodos().first {
            // If there are existing todos, find the max ID
            nextId = loadTodos().max { $0.id < $1.id }?.id?? 0 + 1
        }
    }

    func saveTodos(todos: [TodoItem]) {
        if let encodedData = try? JSONEncoder().encode(todos) {
            try? encodedData.write(to: FileManager.default.urls(for:.documentDirectory, in:.userDomainMask).first!.appendingPathComponent(fileName))
        }
    }

    func loadTodos() -> [TodoItem] {
        guard let filePath = FileManager.default.urls(for:.documentDirectory, in:.userDomainMask).first?.appendingPathComponent(fileName),
              let data = try? Data(contentsOf: filePath),
              let loadedTodos = try? JSONDecoder().decode([TodoItem].self, from: data) else {
            return []
        }
        return loadedTodos
    }

    func addTodo(title: String, completed: Bool = false) -> TodoItem {
        let newTodo = TodoItem(id: nextId, title: title, completed: completed)
        nextId += 1
        var todos = loadTodos()
        todos.append(newTodo)
        saveTodos(todos: todos)
        return newTodo
    }
    func updateTodo(id: Int, title: String?, completed: Bool?) {
        var todos = loadTodos()
        if let index = todos.firstIndex(where: { $0.id == id }) {
            if let newTitle = title {
                todos[index].title = newTitle
            }
            if let newCompletedStatus = completed {
                todos[index].completed = newCompletedStatus
            }
            saveTodos(todos: todos)
        }
    }
    func deleteTodo(id: Int) {
        var todos = loadTodos()
        if let index = todos.firstIndex(where: { $0.id == id }) {
            todos.remove(at: index)
            saveTodos(todos: todos)
            print("Todo with ID \(id) deleted successfully.")
        } else {
            print("No todo found with ID \(id).")
        }
    }
    // Additional methods for editing and deleting todos...
}