//
//  ProfileImageService.swift
//  ImageFeed
//

import Foundation

protocol ProfileImageServiceProtocol {
    var avatarURL: String? { get }
}

enum ProfileImageServiceError: Error, LocalizedError {
    case accessTokenNotDefined
    case repeatedProfileImageRequest
    case errorProfileImageRequest
    
    var errorDescription: String? {
        switch self {
        case .accessTokenNotDefined:
            "Access token not defined"
        case .repeatedProfileImageRequest:
            "Repeated profile image request"
        case .errorProfileImageRequest:
            "Unable to make profile image request"
        }
    }
}

final class ProfileImageService: ProfileImageServiceProtocol {
    
    static let shared = ProfileImageService()
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private(set) var avatarURL: String?
    private var lastToken: String?
    private var lastUsername: String?
    private var task: URLSessionTask?
    
    private let tokenStorage = OAuth2TokenStorage.shared
    
    private init() { }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void){
        assert(Thread.isMainThread)
        
        guard let token = tokenStorage.token else {
            let error = ProfileImageServiceError.accessTokenNotDefined
            ErrorHandler.printError(error, origin: "ProfileImageService.fetchProfileImageURL")
            completion(.failure(error))
            return
        }
        
        guard token != lastToken,
              username != lastUsername else {
            let error = ProfileImageServiceError.repeatedProfileImageRequest
            ErrorHandler.printError(error, origin: "ProfileImageService.fetchProfileImageURL")
            completion(.failure(error))
            return
        }
        task?.cancel()
        
        guard let request = makeProfileImageRequest(token: token, username: username) else {
            let error = ProfileImageServiceError.errorProfileImageRequest
            ErrorHandler.printError(error, origin: "ProfileImageService.fetchProfileImageURL")
            completion(.failure(error))
            return
        }
        
        lastToken = token
        lastUsername = username
        
        task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            switch result {
            case .success(let userResult):
                self?.avatarURL = userResult.profileImage.large
                completion(.success(userResult.profileImage.large))
                NotificationCenter.default.post(name: ProfileImageService.didChangeNotification, object: self)
            case .failure(let error):
                ErrorHandler.printError(error, origin: "ProfileImageService.fetchProfileImageURL", details: "Failed to fetch profile image.")
                completion(.failure(error))
            }
            
            self?.lastToken = nil
            self?.lastUsername = nil
            self?.task = nil
        }
        task?.resume()
    }
    
    func clearData() {
        avatarURL = nil
        lastToken = nil
        lastUsername = nil
        task?.cancel()
        task = nil
    }
    
    private func makeProfileImageRequest(token: String, username: String) -> URLRequest? {
        let apiURL = Constants.defaultBaseURL
        let url = apiURL
            .appendingPathComponent("users")
            .appendingPathComponent(username)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print("[lOG] [ProfileImageService.makeProfileImageRequest] - Profile Image Request: \(request)")
        return request
    }
    
}
