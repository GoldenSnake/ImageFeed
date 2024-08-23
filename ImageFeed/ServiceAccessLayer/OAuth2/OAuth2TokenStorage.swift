//
//  OAuth2TokenStorage.swift
//  ImageFeed
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    //MARK: - Public Properties
    
    var token: String? {
        get {
            keychain.string(forKey: Keys.token.rawValue)
        }
    }
    
    //MARK: - Private Properties
    
    private let keychain = KeychainWrapper.standard
    
        private enum Keys: String {
            case token
        }
        
        func setToken(_ newTokenValue: String) -> Bool {
            keychain.set(newTokenValue, forKey: Keys.token.rawValue)
        }
}
