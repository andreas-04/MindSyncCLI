import Figlet
import ArgumentParser
import Foundation

@main
struct MindSyncCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A Swift todo command-line tool",
        subcommands: [login.self, register.self, logout.self, new.self]
        // , edit.self, delete.self, list.self
    )
    
    mutating func run() throws {
        if let session = Session.load(), session.isLoggedIn {
            print("Help text here")
        } else {
            print("Please login with `MindSyncCLI login`")
        }
    }
}

struct login: ParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Logs into the system")
    
    mutating func run() throws {
        if let session = Session.load(), session.isLoggedIn {
            print("Already Logged In")
        } else {
            print("Username:")
            let username = readLine()
            print("Password:")
            let password = readLine()
            let credentials = ["username": username, "password": password]
            
            guard let jsonData = try? JSONSerialization.data(withJSONObject: credentials, options: []) else {
                print("Failed to serialize credentials into JSON")
                return
            }
            
          let api = API()
          api.makeRequest(method: "POST", endpoint: "user_api/login/", data: jsonData) { result in
              switch result {
              case .success(let responseString):
                  // Decode the JSON response string into a dictionary
                  guard let data = responseString.data(using: .utf8) else {
                      print("Failed to convert response string to data.")
                      return
                  }
                  do {
                      guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                          print("Failed to decode JSON response.")
                          return
                      }
                      
                      // Extract userId and habitTrackerId from the JSON response
                      if let userId = json["userId"] as? Int, let habitTrackerId = json["habitTrackerId"] as? Int {
                          // Create a session with the extracted values
                          let session = Session(isLoggedIn: true, userId: userId, habitTrackerId: habitTrackerId)
                          session.save()
                          print("Login Success")
                      } else {
                          print("Failed to extract userId and habitTrackerId from response.")
                      }
                  } catch {
                      print("Error decoding JSON response: \(error)")
                  }
                  
              case .failure(let error):
                  print("Error: \(error.localizedDescription)")
              }
          }

        }
    }
}

struct register: ParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Register a MindSync account")
    
    mutating func run() throws {
        if let session = Session.load(), session.isLoggedIn {
            print("Currently logged in")
        } else {
            print("email:")
            let email = readLine()
            print("Username:")
            let username = readLine()
            print("Password:")
            let password = readLine()
            let credentials = ["username": username, "email": email, "password": password]
            
            guard let jsonData = try? JSONSerialization.data(withJSONObject: credentials, options: []) else {
                print("Failed to serialize credentials into JSON")
                return
            }
            
            let api = API()
            api.makeRequest(method: "POST", endpoint: "user_api/register/", data: jsonData) { result in
                switch result {
                case .success(let responseString):
                    print(responseString)
                    
                    // Decode the JSON response string into a dictionary
                    guard let data = responseString.data(using: .utf8) else {
                        print("Failed to convert response string to data.")
                        return
                    }
                    do {
                        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                            print("Failed to decode JSON response.")
                            return
                        }
                        
                        // Extract userId and habitTrackerId from the JSON response
                        if let userId = json["userId"] as? Int, let habitTrackerId = json["habitTrackerId"] as? Int {
                            // Create a session with the extracted values
                            let session = Session(isLoggedIn: true, userId: userId, habitTrackerId: habitTrackerId)
                            session.save()
                        } else {
                            print("Failed to extract userId and habitTrackerId from response.")
                        }
                    } catch {
                        print("Error decoding JSON response: \(error)")
                    }
                    
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
        let api = API()
        api.makeRequest(method: "GET", endpoint: "user_api/logout/") { result in
            switch result {
            case .success(_):
                let session = Session(isLoggedIn: false, userId: 0, habitTrackerId: 0) // Resetting session values
                session.save()
                print("Successfully logged out")
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}
struct new: ParsableCommand {
  static let configuration = CommandConfiguration(
    abstract: "Adds a new task or goal",
    subcommands: [task.self]
  )

  mutating func run() throws{
  } 
}
struct task: ParsableCommand{
  @Argument(help: "Task name")
  var name: String
  @Argument(help: "The goal ID to attach this task to")
  var goalId: Int
  static let configuration = CommandConfiguration(abstract: "Add a task subcommand")
  mutating func run() throws{
    if let session = Session.load(), session.isLoggedIn {
      let newTask = Task(name: name, habitTracker: session.habitTrackerId, goal: goalId)
      newTask.sendRequest(method: "POST")
    }else{
      print("Not logged in... try 'mindsync login'")
    }
  }

} 

// struct edit: ParsableCommand {
//   @Argument(help: "The ID of the task to edit")
//   var taskID: String
//   @Option(help: "Edit the task title") 
//   var newTitle: String?
//   @Option(help: "Edit the task completion")
//   var newStatus: Bool?
//   static let configuration = CommandConfiguration(abstract: "Edits a task")
//   mutating func run() throws{
//     let app = TodoApp()
//     var editedTodo: TodoItem?

//     if let newTitle = newTitle, !newTitle.isEmpty {
//       editedTodo = app.editTodo(id: self.taskID, title: newTitle, completed: newStatus)
//       print("Edited todo: \(editedTodo?.title ?? "No changes made"), Completed: \(editedTodo?.completed ?? false)")
//     } else if let newStatus = newStatus {
//       editedTodo = app.updateTodoStatus(id: self.taskID, completed: newStatus)
//       print("Updated todo status: \(editedTodo?.title ?? "No changes made"), Completed: \(editedTodo?.completed ?? false)")
//     }

//     if let editedTodo = editedTodo {
//       print("Edited todo: \(editedTodo.title), Completed: \(editedTodo.completed)")
//     } else {
//       print("No changes made.")
//     }
//   }
// }

// struct delete: ParsableCommand {
//   @Argument var taskID: String
//   static let configuration = CommandConfiguration(abstract: "Deletes a task")
//   mutating func run() throws{
//     let app = TodoApp()
//     let deletionResult = app.deleteTodo(id: self.taskID)
//     if deletionResult {
//         print("Deleted todo with ID: \(self.taskID)")
//     } else {
//         print("Failed to delete todo with ID: \(self.taskID)")
//     }
//   }
// }

// struct list: ParsableCommand {
//   static let configuration = CommandConfiguration(abstract: "List all tasks")
//   mutating func run() throws{
//     let app = TodoApp()
//     _ = app.listTodos()
//   }
// }
