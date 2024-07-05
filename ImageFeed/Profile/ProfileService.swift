//
//  ProfileService.swift
//  ImageFeed
//

import Foundation

enum ProfileServiceError: Error {
    case repeatedProfileRequest
    case failedToCreateProfileRequest
}

final class ProfileService {
    static let shared = ProfileService()
    
    private var lastToken: String?
    private var task: URLSessionTask?
    
    private init() { }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        
        guard token != lastToken else {
            completion(.failure(ProfileServiceError.repeatedProfileRequest))
            return
        }
        task?.cancel()
        
        guard let request = makeProfileRequest(token: token) else {
            completion(.failure(ProfileServiceError.failedToCreateProfileRequest))
            print("Unable to make profile request")
            return
        }
        
        lastToken = token
        let decoder = SnakeCaseJSONDecoder()
        
        task = URLSession.shared.dataMainQueue(for: request) { [weak self] result in
            switch result {
            case .success(let data):
                do {
                    let result = try decoder.decode(ProfileResult.self, from: data)
                    let profile = Profile(profileResult: result)
                    completion(.success(profile))
                    print("Profile data successfully decoded")
                } catch {
                    completion(.failure(error))
                    print("Failed to decode Profile data")
                }
            case .failure(let error):
                completion(.failure(error))
                print("Failed to fetch Profile data")
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
        print("Profile Request: \(request)")
        return request
    }
}
