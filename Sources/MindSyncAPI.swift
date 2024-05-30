import Foundation

class API {
    private let baseURL = "http://localhost:8000/user_api"

    func makeRequest(endpoint: String) {
        let url = baseURL + endpoint
        guard let url = URL(string: url) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in

            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Server error")
                return
            }

            if let data = data {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response:\n\(responseString)")
                }
            }
            exit(EXIT_SUCCESS)
        }

        task.resume()

        // Keep the main thread alive while the request completes
        RunLoop.main.run()
    }
}