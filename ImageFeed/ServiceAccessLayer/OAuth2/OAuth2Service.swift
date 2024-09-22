//
//  0Auth2Service.swift
//  imageFeed
//

import Foundation

enum OAuthServiceError: Error, LocalizedError {
    case failedToCreateTokenRequest
    case repeatedTokenRequest
    case failedToCreateURL
    case failedToSaveToken
    
    var errorDescription: String? {
        switch self {
        case .failedToCreateTokenRequest:
            "Unable to make token request"
        case .repeatedTokenRequest:
            "Repeated token request"
        case .failedToCreateURL:
            "Failed to create URL for token request"
        case .failedToSaveToken:
            "Failed to save token"
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
        
        let storage = OAuth2TokenStorage.shared
        
        task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            switch result {
            case .success(let responseBody):
                let isSuccess = storage.setToken(responseBody.accessToken)
                if isSuccess {
                    completion(.success(responseBody.accessToken))
                    print("[lOG] [OAuth2Servise] - Your token: is saved")
                } else {
                    ErrorHandler.printError(OAuthServiceError.failedToSaveToken, origin: "OAuth2Service.fetchOAuthToken")
                    completion(.failure(OAuthServiceError.failedToSaveToken))
                }
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
        guard let url = urlComponents.url(relativeTo: Constants.unsplashURL)
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

