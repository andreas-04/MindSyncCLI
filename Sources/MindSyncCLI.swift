import Figlet
import ArgumentParser
import Foundation
@main
struct MindSyncCLI: ParsableCommand {
  static let configuration = CommandConfiguration(
    abstract: "A Swift todo command-line tool",
    subcommands: [new.self, edit.self, delete.self, list.self]
  )

}

struct new: ParsableCommand {
  @Argument var name:String
  static let configuration = CommandConfiguration(abstract: "Adds a new task")

  mutating func run() throws{
    let app = TodoApp()
    let newTodo = app.addTodo(title: self.name) 
    print("Added todo: \(newTodo.title)")
  } 
}

struct edit: ParsableCommand {
  @Argument var taskID: String
  @Option(help: "Edit the task title") 
  var newTitle: String
  @Option(help: "Edit the task completion")
  var newStatus: Bool
  static let configuration = CommandConfiguration(abstract: "Edits a task")
  mutating func run() throws{
    let app = TodoApp()
    if let editedTodo = app.editTodo(id: self.taskID, title: newTitle, completed: newStatus) {
        print("Edited todo: \(editedTodo.title), Completed: \(editedTodo.completed)")
    }
  }
}

struct delete: ParsableCommand {
  @Argument var taskID: String
  static let configuration = CommandConfiguration(abstract: "Deletes a task")
  mutating func run() throws{
    let app = TodoApp()
    let deletionResult = app.deleteTodo(id: self.taskID)
    if deletionResult {
        print("Deleted todo with ID: \(self.taskID)")
    } else {
        print("Failed to delete todo with ID: \(self.taskID)")
    }
  }
}

struct list: ParsableCommand {
  static let configuration = CommandConfiguration(abstract: "List all tasks")
  mutating func run() throws{
    let app = TodoApp()
    _ = app.listTodos()
    // print(todos)
  }
}
