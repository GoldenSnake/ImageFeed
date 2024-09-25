//
//  Profile.swift
//  ImageFeed
//

import Foundation

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
    
    init(profileResult: ProfileResult) {
        username = profileResult.username
        
        if let lastName = profileResult.lastName {
            name = profileResult.firstName + " " + lastName
        } else {
            name = profileResult.firstName
        }
        
        loginName = "@" + profileResult.username
        bio = profileResult.bio
    }
    
    init(username: String, name: String, loginName: String, bio: String?) {
            self.username = username
            self.name = name
            self.loginName = loginName
            self.bio = bio
        }
}
