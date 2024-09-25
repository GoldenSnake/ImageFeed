import ImageFeed
import UIKit

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ImageFeed.ProfilePresenterProtocol?
    var avatarUpdated = false
    var alertPresented = false
    var alert: UIAlertController?

    func updateProfile(name: String, login: String, bio: String?) {

    }

    func updateAvatar(url: URL) {
        avatarUpdated = true
    }

    func presentAlert(_ alert: UIAlertController) {
        alertPresented = true
        self.alert = alert
    }
}
