//
//  0Auth2Service.swift
//  imageFeed
//

import Foundation

enum OAuthServiceError: Error, LocalizedError {
    case failedToCreateTokenRequest
    case repeatedTokenRequest
    case failedToCreateURL
    
    var errorDescription: String? {
            switch self {
            case .failedToCreateTokenRequest:
                "Unable to make token request"
            case .repeatedTokenRequest:
                "Repeated token request"
            case .failedToCreateURL:
                "Failed to create URL for token request"
            }
        }
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private var lastCode: String?
    private var task: URLSessionTask?
    
    private init() { }
    
    func fetchOAuthToken(with code: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        
        guard code != lastCode else {
            let error = OAuthServiceError.repeatedTokenRequest
            ErrorHandler.printError(error, origin: "OAuth2Service.fetchOAuthToken")
            completion(.failure(error))
            return
        }
        task?.cancel()
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            let error = OAuthServiceError.failedToCreateTokenRequest
            ErrorHandler.printError(error, origin: "OAuth2Service.fetchOAuthToken")
            completion(.failure(error))
            return
        }
        
        lastCode = code
        
        let storage = OAuth2TokenStorage()
        
        task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            switch result {
            case .success(let responseBody):
                storage.token = responseBody.accessToken
                completion(.success(responseBody.accessToken))
            case .failure(let error):
                ErrorHandler.printError(error, origin: "OAuth2Service.fetchOAuthToken", details: "Failed to fetch Token")
                completion(.failure(error))
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
            let error = OAuthServiceError.failedToCreateURL
            ErrorHandler.printError(error, origin: "OAuthService.makeOAuthTokenRequest")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        print("[lOG] [OAuth2Service.makeOAuthTokenRequest] - Request URL: \(request)")
        return request
    }
}

