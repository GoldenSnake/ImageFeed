@testable import ImageFeed
import Foundation

final class ProfileServiceMock: ProfileServiceProtocol {
    var profile: ImageFeed.Profile?

    init(profile: ImageFeed.Profile) {
        self.profile = profile
    }
}
