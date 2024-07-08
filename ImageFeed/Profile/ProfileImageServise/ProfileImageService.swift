//
//  ProfileImageService.swift
//  ImageFeed
//

import Foundation

enum ProfileImageServiceError: Error {
    case accessTokenNotDefined
    case repeatedProfileImageRequest
    case errorProfileRequest
}

final class ProfileImageService {
    
    static let shared = ProfileImageService()
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private(set) var avatarURL: String?
    private var lastToken: String?
    private var lastUsername: String?
    private var task: URLSessionTask?
    
    private let tokenStorage = OAuth2TokenStorage()
    
    private init() { }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void){
        assert(Thread.isMainThread)
        
        guard let token = tokenStorage.token else {
            completion(.failure(ProfileImageServiceError.accessTokenNotDefined))
            return
        }
        
        guard token != lastToken,
        username != lastUsername else {
            completion(.failure(ProfileImageServiceError.repeatedProfileImageRequest))
            return
        }
        task?.cancel()
        
        guard let request = makeProfileImageRequest(token: token, username: username) else {
            completion(.failure(ProfileImageServiceError.errorProfileRequest))
            print("Unable to make profile request")
            return
        }
        
        lastToken = token
        lastUsername = username
        let decoder = SnakeCaseJSONDecoder()
        
        task = URLSession.shared.dataMainQueue(for: request) { [weak self] result in
            switch result {
            case .success(let data):
                do {
                    let result = try decoder.decode(UserResult.self, from: data)
                    
                    self?.avatarURL = result.profileImage.large
                    completion(.success(result.profileImage.large))
                    print("Profile image successfully decoded")
                    NotificationCenter.default.post(name: ProfileImageService.didChangeNotification, object: self)
                } catch {
                    completion(.failure(error))
                    print("Failed to decode profile image: \(error)")
                }
            case .failure(let error):
                completion(.failure(error))
                print("Failed to fetch profile image. \(error.localizedDescription)")
            }
            
            self?.lastToken = nil
            self?.lastUsername = nil
            self?.task = nil
        }
        task?.resume()
    }
    
    private func makeProfileImageRequest(token: String, username: String) -> URLRequest? {
        guard let apiURL = Constants.apiURL else {return nil}
        let url = apiURL
            .appendingPathComponent("users")
            .appendingPathComponent(username)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print("Profile Image Request: \(request)")
        return request
    }
    
}
