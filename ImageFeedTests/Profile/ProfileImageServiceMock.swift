@testable import ImageFeed
import Foundation

final class ProfileImageServiceMock: ProfileImageServiceProtocol {
    var avatarURL: String?

    init(avatarURL: String? = nil) {
        self.avatarURL = avatarURL
    }
}
