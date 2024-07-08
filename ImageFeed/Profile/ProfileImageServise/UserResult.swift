//
//  UserResult.swift
//  ImageFeed
//

import Foundation

struct ProfileImage: Codable {
    let small: String
    let medium: String
    let large: String
}

struct UserResult: Codable {
    let profileImage: ProfileImage
}
