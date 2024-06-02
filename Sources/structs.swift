import Foundation

// class TodoItem: Codable {
//     var id: String 
//     var title: String
//     var completed: Bool
    
//     init(title: String, completed: Bool = false) {
//         self.id = UUID().uuidString
//         self.title = title
//         self.completed = completed
//     }
// }

struct Task {
    var name: String
    var completed: Bool
    var goal: Int
    var habitTracker: Int
    init(name: String, habitTracker: Int, goal: Int){
        self.name = name
        self.habitTracker = habitTracker
        self.goal = goal
        self.completed = false
    }
    func sendRequest(method: String){
        let data: [String: Any] = ["name": self.name, "completed": self.completed, "goal": self.goal, "habit_tracker": self.habitTracker]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: []) else {
            print("Failed to serialize data into JSON")
            return 
        }

        let api = API()
        api.makeRequest(method: method, endpoint: "api/tasks/", data:jsonData){ result in
            switch result {
            case .success(_):
                return
            case .failure(_):
                print("Failed to create task with name \(self.name)")
        }
      }        
    }


}

struct Goal {
    var name: String
    var habitTracker: Int
}




