//
//  0Auth2Service.swift
//  imageFeed
//

import Foundation

enum OAuthServiceError: Error {
    case failedToCreateTokenRequest
    case repeatedTokenRequest
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private var lastCode: String?
    private var task: URLSessionTask?
    
    private init() { }
    
    func fetchOAuthToken(with code: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        
        guard code != lastCode else {
            completion(.failure(OAuthServiceError.repeatedTokenRequest))
            print("Error: Repeated Token Request")
            return
        }
        task?.cancel()
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(OAuthServiceError.failedToCreateTokenRequest))
            print("Unable to make token request")
            return
        }
        
        lastCode = code
        
        let decoder = SnakeCaseJSONDecoder()
        let storage = OAuth2TokenStorage()
        
        task = URLSession.shared.dataMainQueue(for: request) { [weak self] result in
            switch result {
            case .success(let data):
                do {
                    let tokenResponse = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    
                    storage.token = tokenResponse.accessToken
                    
                    completion(.success(tokenResponse.accessToken))
                    print("Token successfully decoded")
                } catch {
                    completion(.failure(error))
                    print("Failed to decode Token")
                }
            case .failure(let error):
                completion(.failure(error))
                print("Failed to fetch Token")
            }
            self?.lastCode = nil
            self?.task = nil
        }
        task?.resume()
    }
    
    // MARK: - makeOAuthTokenRequest
    
    private func makeOAuthTokenRequest(code: String?) -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.path = Constants.authPath
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        guard let url = urlComponents.url(relativeTo: Constants.defaultBaseURL)
        else {
            print("Failed to create URL")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        print("URL: \(request)")
        return request
    }
}

