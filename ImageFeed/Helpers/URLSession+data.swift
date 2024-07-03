//
//  URLSession+data.swift
//  ImageFeed
//


import Foundation

enum NetworkError: Error {  
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

extension URLSession {
    func data(
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
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                    print("HTTP Error: \(String(describing: error))")
                }
            } else if let error = error {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
                print("URLRequest Error: \(error)")
            } else {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
                print("URLSession Error")
            }
        }
        
        return task
    }
}
