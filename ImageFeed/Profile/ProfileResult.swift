//
//  ProfileResult.swift
//  ImageFeed
//

import UIKit

struct ProfileResult: Decodable {
    let firstName: String
    let lastName: String?
    let username: String
    let bio: String?
}
