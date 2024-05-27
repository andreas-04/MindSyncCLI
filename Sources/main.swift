import Foundation

let todoApp = TodoApp()

// Load existing todos
var todos = todoApp.loadTodos()
print("Current Todos:")
for todo in todos {
    print("\(todo.title)")
}

// Add a new todo
todos.append(TodoItem(title: "Learn Swift", completed: false))
todoApp.saveTodos(todos: todos)

// List todos
print("\nUpdated Todos:")
for todo in todos {
    print("\(todo.title)")
}