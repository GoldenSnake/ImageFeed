//
//  OAuth2TokenStorage.swift
//  ImageFeed
//

import Foundation

final class OAuth2TokenStorage {
    
    //MARK: - Public Properties
    
    var token: String? {
            get {
                return userDefaults.string(forKey: Keys.token.rawValue)
            }
            set {
                userDefaults.set(newValue, forKey: Keys.token.rawValue)
                print("Your token: \(token ?? "") is saved")
            }
        }
    
    //MARK: - Private Properties
    
    private enum Keys: String {
            case token
        }
    
    private let userDefaults = UserDefaults.standard
}
