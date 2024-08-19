//
//  ProfileService.swift
//  ImageFeed
//

import Foundation

enum ProfileServiceError: Error, LocalizedError {
    case repeatedProfileRequest
    case failedToCreateProfileRequest
    
    var errorDescription: String? {
        switch self {
        case .repeatedProfileRequest:
            "Repeated profile request"
        case .failedToCreateProfileRequest:
            "Failed to create profile request"
        }
    }
}

final class ProfileService {
    static let shared = ProfileService()
    
    private var lastToken: String?
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    
    private init() { }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        
        guard token != lastToken else {
            let error = ProfileServiceError.repeatedProfileRequest
            ErrorHandler.printError(error, origin: "ProfileServise.fetchProfile")
            completion(.failure(error))
            return
        }
        task?.cancel()
    
        guard let request = makeProfileRequest(token: token) else {
            let error = ProfileServiceError.failedToCreateProfileRequest
            ErrorHandler.printError(error, origin: "ProfileServise.fetchProfile")
            completion(.failure(error))
            return
        }
        
        lastToken = token
        
        task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let profileResult):
                            let profile = Profile(profileResult: profileResult)
                            self?.profile = profile
                            completion(.success(profile))
            case .failure(let error):
                
                ErrorHandler.printError(error, origin: "ProfileServise.fetchProfile", details: "Failed to fetch Profile data.")
                completion(.failure(error))
            }
            
            self?.lastToken = nil
            self?.task = nil
        }
        task?.resume()
    }
    
    
    
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let apiURL = Constants.apiURL else {return nil}
        let url = apiURL.appendingPathComponent("me")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print("[lOG] [ProfileService.makeProfileRequest] - Profile Request: \(request)")
        return request
    }
}
