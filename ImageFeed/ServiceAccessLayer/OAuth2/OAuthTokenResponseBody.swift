//
//  OAuthTokenResponseBody.swift
//  ImageFeed
//

import Foundation

struct OAuthTokenResponseBody: Codable {
    let accessToken: String
    
    private enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}
