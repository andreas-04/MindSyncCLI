import Figlet
import ArgumentParser
import Foundation
@main
struct MindSyncCLI: ParsableCommand {
  static let configuration = CommandConfiguration(
    abstract: "A Swift todo command-line tool",
    subcommands: [login.self, register.self, logout.self, new.self, edit.self, delete.self, list.self]
  )
  mutating func run() throws{
    let sessionManager = SessionManager()
    if let session = sessionManager.loadSession(), session.isLoggedIn {
      print("Help text here")
    } else{
      print("Please login with `MindSyncCLI login`")
    }
  }
}

struct login: ParsableCommand{
  static let configuration = CommandConfiguration(abstract: "Logs into the system")
  mutating func run() throws{
    let sessionManager = SessionManager()
    if let session = sessionManager.loadSession(), session.isLoggedIn {
      print("Already Logged In")
    } else{
      print("Username:")
      let username = readLine()
      print("Password:")
      let password = readLine()
      let credentials = ["password": password, "username": username]
      guard let jsonData = try? JSONSerialization.data(withJSONObject: credentials, options: []) else {
        print("Failed to serialize credentials into JSON")
        return
      }
      let api = API()
      api.makeRequest(method: "POST", endpoint: "/login/", data:jsonData){ result in
        switch result {
        case .success( _):
          // print("Response:\n\(responseString)")
          let session = Session(isLoggedIn: true)
          sessionManager.saveSession(session: session)
          print("Successfully logged in")
        case .failure(let error):
          print("Error: \(error.localizedDescription)")
        }
      }
    }
  }
}

struct register: ParsableCommand{
  static let configuration = CommandConfiguration(abstract: "Register a MindSync account")
  mutating func run() throws {
    let sessionManager = SessionManager()
    let api = API()
    if let session = sessionManager.loadSession(), session.isLoggedIn {
      print("Currently logged in")
    }else{
      print("email:")
      let email = readLine()
      print("Username:")
      let username = readLine()
      print("Password:")
      let password = readLine()
      let credentials = ["username": username, "email": email, "password": password ]
      guard let jsonData = try? JSONSerialization.data(withJSONObject: credentials, options: []) else {
        print("Failed to serialize credentials into JSON")
        return
      }
      api.makeRequest(method: "POST", endpoint: "/register/", data:jsonData){ result in
        switch result {
        case .success( _):
          // let credentials2  = ["username": username, "password": password ]
          //  guard let jsonData = try? JSONSerialization.data(withJSONObject: credentials2, options: []) else {
          //   print("Failed to serialize credentials into JSON")
          //   return
          // }
          // api.makeRequest(method: "POST", endpoint: "/login/", data:jsonData){ result in
          //   switch result {
          //   case .success( _):

          //     let session = Session(isLoggedIn: true)
          //     sessionManager.saveSession(session: session)
          //   case .failure(let error):
          //     print("Error: \(error.localizedDescription)")
          //   }
          // }
          print("Successfully Registered!")
        case .failure(let error):
          print("Error: \(error.localizedDescription)")
        }
      }

    }
  }
}

struct logout: ParsableCommand {
  static let configuration = CommandConfiguration(abstract: "Log out of the system")

  mutating func run() throws {
    let sessionManager = SessionManager()
    let api = API()
    api.makeRequest(method: "GET", endpoint: "/logout/"){
      result in
      switch result {
      case .success(_):
        // print("Response:\n\(responseString)")
        let session = Session(isLoggedIn: false)
        sessionManager.saveSession(session: session)
        print("Successfully logged out")
      case .failure(let error):
        print("Error: \(error.localizedDescription)")
      }
    }
  }
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
  @Argument(help: "The ID of the task to edit")
  var taskID: String
  @Option(help: "Edit the task title") 
  var newTitle: String?
  @Option(help: "Edit the task completion")
  var newStatus: Bool?
  static let configuration = CommandConfiguration(abstract: "Edits a task")
  mutating func run() throws{
    let app = TodoApp()
    var editedTodo: TodoItem?

    if let newTitle = newTitle, !newTitle.isEmpty {
      editedTodo = app.editTodo(id: self.taskID, title: newTitle, completed: newStatus)
      print("Edited todo: \(editedTodo?.title ?? "No changes made"), Completed: \(editedTodo?.completed ?? false)")
    } else if let newStatus = newStatus {
      editedTodo = app.updateTodoStatus(id: self.taskID, completed: newStatus)
      print("Updated todo status: \(editedTodo?.title ?? "No changes made"), Completed: \(editedTodo?.completed ?? false)")
    }

    if let editedTodo = editedTodo {
      print("Edited todo: \(editedTodo.title), Completed: \(editedTodo.completed)")
    } else {
      print("No changes made.")
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
  }
}
