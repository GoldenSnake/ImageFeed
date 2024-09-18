//
//  OAuth2TokenStorage.swift
//  ImageFeed
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    static let shared = OAuth2TokenStorage()
    
    private init() { }
    
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
    
    //MARK: - Public Methods
    
    func setToken(_ newTokenValue: String) -> Bool {
        keychain.set(newTokenValue, forKey: Keys.token.rawValue)
    }
    
    func removeToken() {
        keychain.removeObject(forKey: Keys.token.rawValue)
    }
}
