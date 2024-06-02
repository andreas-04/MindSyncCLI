import Foundation

struct Session: Codable {
    var isLoggedIn: Bool
    var userId: Int
    var habitTrackerId: Int

    static func getSessionFilePath() -> URL? {
        let fileManager = FileManager.default
        if let directory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            return directory.appendingPathComponent("session.json")
        }
        return nil
    }

    func save() {
        guard let filePath = Session.getSessionFilePath() else { return }
        do {
            let data = try JSONEncoder().encode(self)
            try data.write(to: filePath)
            // print("Session saved.")
        } catch {
            print("Failed to save session: \(error)")
        }
    }
   static func load() -> Session? {
        guard let filePath = Session.getSessionFilePath() else { return nil }

        do {
            let data = try Data(contentsOf: filePath)
            let session = try JSONDecoder().decode(Session.self, from: data)
            return session
        } catch {
            // print("No existing session found or failed to load session: \(error)")
            return nil
        }
    }
}
