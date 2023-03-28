import Foundation


func fetchRequest(completion: @escaping (Result<Data, ApiRequestError>) -> Void) {
    guard let url = URL(string: "http://127.0.0.1:3000/api/v1/mp/sdk/payment") else {
        fatalError("need correct url")
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    
    let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
        if error != nil {
            completion(.failure(.unhandleError))
            return
        }
        
        guard let data = data,
              let response = response as? HTTPURLResponse else {
            completion(.failure(ApiRequestError.unhandleError))
            return
        }
        
        let status = response.statusCode
        guard (200...299).contains(status) else {
            if status == 404 {
                completion(.failure(.notFound))
            } else {
                completion(.failure(.backendError(message: "Some error ocurred")))
            }
            return
        }
        
        completion(.success(data))
    }
    
    task.resume()
}

enum ApiRequestError: Equatable, Error, CustomStringConvertible {
    case notFound
    case imageNotFound
    case wrongUrl
    case serialize(identifier: String)
    case httpUrlResponseCast
    case unhandleError
    case backendError(message: String)
    
    var message: String {
        switch self {
        case .notFound:
            return "Not found"
        case .imageNotFound:
            return "Image not found."
        case .wrongUrl:
            return "Wrong URL"
        case .serialize(let identifier):
            return "Error serializing from object identifier \(identifier)"
        case .backendError(message: let message): return message
        case .httpUrlResponseCast:
            return "Could not cast HTTPUrlResponse"
        case .unhandleError:
            return "Unhandled error from backend"
        }
    }
    
    public var description: String {
        return "🧨⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽⎽\nmessage: \(self.message)\n⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺⎺"
    }
}

