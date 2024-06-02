import Foundation

class API {
    private let baseURL = "http://localhost:8000/"

    //for debugging
    private func printRequest(_ request: URLRequest) {
        print("Request URL: \(request.url?.absoluteString ?? "No URL")")
        print("HTTP Method: \(request.httpMethod ?? "No HTTP Method")")
        print("Headers: \(request.allHTTPHeaderFields ?? [:])")
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("HTTP Body: \(bodyString)")
        } else {
            print("No HTTP Body")
        }
    }

    func makeRequest(method: String, endpoint: String, data: Data? = nil, completion: @escaping (Result<String, Error>) -> Void) {
        let url = baseURL + endpoint
        guard let url = URL(string: url) else {
            completion(.failure(NSError(domain: "InvalidURL", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("nZYXJlNm6GqIL2yAiLvsAUYZQ0mwbWNw", forHTTPHeaderField: "x-csrftoken")

        if let data = data {
            request.httpBody = data
        }
        printRequest(request)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // print("Data task completed")
            if let error = error {
                print("Error received: \(error.localizedDescription)")
                completion(.failure(error))
                exit(EXIT_FAILURE)
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                // print("Response is not HTTPURLResponse")
                completion(.failure(NSError(domain: "ServerError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Server error"])))
                exit(EXIT_FAILURE)

            }
            
            // print("HTTP Response status code: \(httpResponse.statusCode)")
            guard (200...299).contains(httpResponse.statusCode) else {
                print("Server returned error status code: \(httpResponse.statusCode)")
                completion(.failure(NSError(domain: "ServerError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Server error"])))
                exit(EXIT_FAILURE)
            }

            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                //  print("Response data received: \(responseString)")
                completion(.success(responseString))
                exit(EXIT_SUCCESS)
            } else {
                // print("No data or data encoding error")
                completion(.failure(NSError(domain: "DataError", code: 3, userInfo: [NSLocalizedDescriptionKey: "No data or data encoding error"])))
                exit(EXIT_FAILURE)
            }
        }
        task.resume()
        RunLoop.main.run()
        
    }
}

