import Foundation

class TodoApp {
    private let fileName = "todos.json"

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
        let newTodo = TodoItem( title: title, completed: completed)
        var todos = loadTodos()
        todos.append(newTodo)
        saveTodos(todos: todos)
        return newTodo
    }
    func editTodo(id: String, title: String?, completed: Bool?) -> TodoItem? {
        var todos = loadTodos()
        if let index = todos.firstIndex(where: { $0.id == id }) {
            let todoToUpdate = todos[index]
            if let newTitle = title {
                todoToUpdate.title = newTitle
            }
            if let newCompletedStatus = completed {
                todoToUpdate.completed = newCompletedStatus
            }
            todos[index] = todoToUpdate
            saveTodos(todos: todos)
            return todoToUpdate
        } else {
            return nil
        }
    }
    func deleteTodo(id: String) -> Bool {
        var todos = loadTodos()
        if let index = todos.firstIndex(where: { $0.id == id }) {
            todos.remove(at: index)
            saveTodos(todos: todos)
            return true
        } else {
            return false
        }
    }
    func listTodos() -> [TodoItem] {
        let todos = loadTodos()
        for todo in todos {
            print("ID: \(todo.id), Title: \(todo.title), Completed: \(todo.completed)")
        }
        return todos

    }
}