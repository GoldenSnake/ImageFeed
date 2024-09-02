import UIKit

enum SplashViewControllerError: Error, LocalizedError {
    case invalidDestination
    
    var errorDescription: String? {
        switch self {
        case .invalidDestination:
            "Invalid destination for AuthNavigationController"
        }
    }
}

final class SplashViewController: UIViewController {
    // MARK: - Private Properties
    
    private let oAuth2TokenStorage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    private lazy var logoImage: UIImageView = {
        let image = UIImageView(image: UIImage(named: "splash_screen_logo"))
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    // MARK: - Overridden Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypBlack
        view.addSubview(logoImage)
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = oAuth2TokenStorage.token {
            fetchProfile(token)
        } else {
            // Show Auth Screen
            guard let navigationController = UIStoryboard(name: "Main", bundle: .main)
                .instantiateViewController(withIdentifier: "AuthNavigationController") as? UINavigationController,
                  let authViewController = navigationController.viewControllers[0] as? AuthViewController
            else {
                ErrorHandler.printError(SplashViewControllerError.invalidDestination, origin: "SplashViewController.viewDidAppear")
                return
            }
            authViewController.delegate = self
            
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    // MARK: - Private Methods
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            logoImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            logoImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    
    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self else { return }
            
            switch result {
            case .success(let profile):
                profileImageService.fetchProfileImageURL(username: profile.username) { imageResult in
                    if case .failure(let error) = imageResult {
                        ErrorHandler.printError(error, origin: "SplashViewController.fetchProfile", details: "Error set profile image")
                    }
                }
                
                self.switchToTabBarController()
                
            case .failure(let error):
                ErrorHandler.printError(error, origin: "SplashViewController.fetchProfile", details: "Error set profile")
            }
        }
    }
}

// MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {
    
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
    }
}


