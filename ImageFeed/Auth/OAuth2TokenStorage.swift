//
//  OAuth2TokenStorage.swift
//  ImageFeed
//

import Foundation

final class OAuth2TokenStorage {
    
    //MARK: - Public Properties
    static let shared = OAuth2TokenStorage()
    
    var token: String? {
        get {
            return userDefaults.string(forKey: "accessToken")
        }
        set {
            userDefaults.setValue(newValue, forKey: "accessToken")
            print("Your token is \(token ?? "") is saved")
        }
    }
    
    //MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
}
