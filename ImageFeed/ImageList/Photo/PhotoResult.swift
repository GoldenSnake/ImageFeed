
import Foundation

struct UrlsResult: Codable {
    let thumb: String
    let full: String
}

struct PhotoResult: Codable {
    let id: String
    let height: Int
    let width: Int
    let createdAt: Date?
    let description: String?
    let urls: UrlsResult
    let likedByUser: Bool
}
