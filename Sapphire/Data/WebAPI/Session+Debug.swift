import Foundation
import APIKit

extension Session {
    class SessionAdapter: URLSessionAdapter {
        override func createTask(with URLRequest: URLRequest, handler: @escaping (Data?, URLResponse?, Error?) -> Void) -> SessionTask {
            logRequest(URLRequest)
            return super.createTask(with: URLRequest) { [weak self] data, response, error in
                self?.logResponse(for: URLRequest, response: response, error: error, responseData: data)
                handler(data, response, error)
            }
        }

        private func logRequest(_ request: URLRequest) {
            guard let url = request.url, let method = request.httpMethod, let headers = request.allHTTPHeaderFields else {
                return
            }

            logHTTPHeaders(headers, isRequest: true)

            if method != "GET" {
                guard let httpBody = request.httpBody, let postData = String(data: httpBody, encoding: .utf8) else {
                    return
                }
                print("\(method) [\(url.absoluteString)] started with \(postData)")
            } else {
                print("\(method) [\(url.absoluteString)] started")
            }
        }

        private func logResponse(for request: URLRequest, response: URLResponse?, error: Error?, responseData: Data?) {
            guard let url = request.url,
                let method = request.httpMethod,
                let response = response as? HTTPURLResponse,
                let responseData = responseData else {
                print("error: Unexpected response")
                return
            }

            logHTTPHeaders(response.allHeaderFields, isRequest: false)

            let responseObject: Any
            if let contentType = response.allHeaderFields["Content-Type"] as? String, contentType.contains("application/json") {
                responseObject = (try? JSONSerialization.jsonObject(with: responseData, options: [])) ?? String(data: responseData, encoding: .utf8) ?? "<Unknown>"
            } else {
                responseObject = String(data: responseData, encoding: .utf8) ?? "<Unknown>"
            }

            if let error = error {
                print("\(method) [\(url.absoluteString)] got error: \(error) got response: \(response.statusCode)\n\(responseObject)")
            } else {
                print("\(method) [\(url.absoluteString)] got response: \(response.statusCode)\n\(responseObject)")
            }
        }

        private func logHTTPHeaders(_ headers: [AnyHashable: Any], isRequest: Bool) {
            let prefix: String

            if isRequest {
                print("[HTTP Request Headers]")
                prefix = ">"
            } else {
                print("[HTTP Response Headers]")
                prefix = "<"
            }

            for (key, value) in headers {
                print("\(prefix) \(key): \(value)")
            }
        }
    }

    static let verbose = Session(adapter: SessionAdapter(configuration: URLSessionConfiguration.default))
}
