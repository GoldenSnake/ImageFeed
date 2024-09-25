//
//  ProfileViewController.swift
//  ImageFeed
//

import UIKit
import Kingfisher

public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    func updateProfile(name: String, login: String, bio: String?)
    func updateAvatar(url: URL)
    func presentAlert(_ alert: UIAlertController)
}

final class ProfileViewController: UIViewController & ProfileViewControllerProtocol {
    
    // MARK: - Public Properties
    var presenter: ProfilePresenterProtocol?
    
    var avatarImage: UIImageView?
    var nameLabel: UILabel?
    var loginLabel: UILabel?
    var descriptionLabel: UILabel?
    
    // MARK: - Private Properties
    private var logoutButton: UIButton?
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var logoutService = ProfileLogoutService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAvatarImage()
        setupNameLabel()
        setupLoginLabel()
        setupDescriptionLabel()
        setupLogoutButton()
        view.backgroundColor = .ypBlack
        
        presenter?.viewDidLoad()
    }
    
    // MARK: - Overridden Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - ProfileViewControllerProtocol
    func updateProfile(name: String, login: String, bio: String?) {
        guard let nameLabel = self.nameLabel else {return}
        nameLabel.text = name
        guard let loginLabel = self.loginLabel else {return}
        loginLabel.text = login
        guard let descriptionLabel = self.descriptionLabel else {return}
        guard let bio = bio else {return}
        descriptionLabel.text = bio
    }
    
    func updateAvatar(url: URL) {
        guard let avatarImage = self.avatarImage else {return}
        avatarImage.kf.setImage(with: url,
                                placeholder: UIImage(named: "placeholder_avatar"),
                                options: [.processor(RoundCornerImageProcessor(cornerRadius: 61)),
                                          .cacheSerializer(FormatIndicatedCacheSerializer.png)])
    }
    
    func presentAlert(_ alert: UIAlertController) {
        self.present(alert, animated: true)
    }
    
    // MARK: - Private Methods
    
    private func setupAvatarImage() {
        let profileImage = UIImage(named: "placeholder_avatar")
        
        
        let avatarImage = UIImageView()
        avatarImage.image = profileImage
        avatarImage.layer.cornerRadius = avatarImage.frame.size.width / 2
        avatarImage.clipsToBounds = true
        
        avatarImage.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(avatarImage)
        
        NSLayoutConstraint.activate([
            avatarImage.heightAnchor.constraint(equalToConstant: 70),
            avatarImage.widthAnchor.constraint(equalToConstant: 70),
            avatarImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
        
        self.avatarImage = avatarImage
    }
    
    private func setupNameLabel() {
        let nameLabel = UILabel()
        
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        nameLabel.textColor = .ypWhite
        nameLabel.numberOfLines = 0
        nameLabel.accessibilityIdentifier = "nameLabel"
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16).isActive = true
        if let avatarImage {
            NSLayoutConstraint.activate([
                nameLabel.topAnchor.constraint(equalTo: avatarImage.bottomAnchor, constant: 8),
                nameLabel.leadingAnchor.constraint(equalTo: avatarImage.leadingAnchor)
            ])
        }
        
        self.nameLabel = nameLabel
    }
    
    private func setupLoginLabel() {
        let loginLabel = UILabel()
        
        loginLabel.font = UIFont.systemFont(ofSize: 13)
        loginLabel.textColor = .ypWhite
        loginLabel.numberOfLines = 0
        loginLabel.accessibilityIdentifier = "loginLabel"
        
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginLabel)
        
        loginLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16).isActive = true
        if let avatarImage {
            loginLabel.leadingAnchor.constraint(equalTo: avatarImage.leadingAnchor).isActive = true
        }
        if let nameLabel {
            loginLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        }
        
        self.loginLabel = loginLabel
    }
    
    private func setupDescriptionLabel() {
        let descriptionLabel = UILabel()
        
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        descriptionLabel.textColor = .ypWhite
        descriptionLabel.numberOfLines = 0
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        descriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16).isActive = true
        if let avatarImage {
            descriptionLabel.leadingAnchor.constraint(equalTo: avatarImage.leadingAnchor).isActive = true
        }
        if let loginLabel {
            descriptionLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 8).isActive = true
        }
        
        self.descriptionLabel = descriptionLabel
    }
    
    private func setupLogoutButton() {
        let logoutButton = UIButton.systemButton(
            with: UIImage(named: "logout_button") ?? UIImage(),
            target: self,
            action: #selector(Self.didTapLogoutButton)
        )
        
        logoutButton.tintColor = .ypRed
        logoutButton.accessibilityIdentifier = "Logout"
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        
        if let avatarImage {
            logoutButton.centerYAnchor.constraint(equalTo: avatarImage.centerYAnchor).isActive = true
        }
        
        self.logoutButton = logoutButton
    }
    
    // MARK: - @objc
    
    @objc
    private func didTapLogoutButton() {
        presenter?.logout()
    }
    
}
