
import UIKit

public protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func logout()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    
    // MARK: - Public Properties
    weak var view: ProfileViewControllerProtocol?
    
    // MARK: - Private Properties
    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    private let logoutService = ProfileLogoutService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    init(profileService: ProfileServiceProtocol = ProfileService.shared,
         profileImageService: ProfileImageServiceProtocol = ProfileImageService.shared) {
        self.profileService = profileService
        self.profileImageService = profileImageService
    }
    
    // MARK: - ProfilePresenterProtocol
    func viewDidLoad() {
        if let profile = profileService.profile {
            view?.updateProfile(name: profile.name, login: profile.loginName, bio: profile.bio)
        }
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                guard let self else { return }
                self.updateAvatar()
            }
        updateAvatar()
    }
    // logout
    func logout() {
        let alertController = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены что хотите выйти?",
            preferredStyle: .alert
        )
        let yesAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            self?.logoutService.logout()
            
            if let window = UIApplication.shared.windows.first {
                window.rootViewController = SplashViewController()
            }
        }
        alertController.addAction(yesAction)
        
        let noAction = UIAlertAction(title: "Нет", style: .default)
        alertController.addAction(noAction)
        
        view?.presentAlert(alertController)
    }
    
    // MARK: - Private Methods
    private func updateAvatar() {
        guard let avatarURL = profileImageService.avatarURL,
              let url = URL(string: avatarURL) else { return }
        view?.updateAvatar(url: url)
    }
}
