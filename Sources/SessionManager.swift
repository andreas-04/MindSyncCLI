import Foundation

struct Session: Codable {
    var isLoggedIn: Bool
}

class SessionManager {

    func getSessionFilePath() -> URL? {
        let fileManager = FileManager.default
        if let directory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            return directory.appendingPathComponent("session.json")
        }
        return nil
    }

    func saveSession(session: Session) {
        guard let filePath = getSessionFilePath() else { return }
        do {
            let data = try JSONEncoder().encode(session)
            try data.write(to: filePath)
            // print("Session saved.")
        } catch {
            print("Failed to save session: \(error)")
        }
    }

    func loadSession() -> Session? {
        guard let filePath = getSessionFilePath() else { return nil }

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