//
//  URLSession+data.swift
//  ImageFeed
//


import Foundation

enum NetworkError: Error, LocalizedError {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    
    var errorDescription: String? {
        switch self {
        case .httpStatusCode(let code):
            "Network Error - Код ошибки \(code)"
        case .urlRequestError(let requestError):
            "URL Request Error - \(requestError.localizedDescription)"
        case .urlSessionError:
            "URL Session Error"
        }
    }
}

extension URLSession {
    func dataMainQueue(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request) { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    let networkError = NetworkError.httpStatusCode(statusCode)
                    ErrorHandler.printError(networkError, origin: "URLSession.dataMainQueue")
                    fulfillCompletionOnTheMainThread(.failure(networkError))
                }
            } else if let error = error {
                let networkError = NetworkError.urlRequestError(error)
                ErrorHandler.printError(networkError, origin: "URLSession.dataMainQueue")
                fulfillCompletionOnTheMainThread(.failure(networkError))
            } else {
                let networkError = NetworkError.urlSessionError
                ErrorHandler.printError(networkError, origin: "URLSession.dataMainQueue")
                fulfillCompletionOnTheMainThread(.failure(networkError))
            }
        }
        
        return task
    }
    
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let task = dataMainQueue(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let result = try SnakeCaseJSONDecoder().decode(T.self, from: data)
                    print("[lOG] [URLSession.objectTask] - Successfully decoded")
                    completion(.success(result))
                } catch {
                    ErrorHandler.printError(error,
                                            origin: "URLSession.objectTask",
                                            details: "Ошибка декодирования данных: \(String(data: data, encoding: .utf8) ?? " ")")
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return task
    }
}
