//
//  ProfileViewController.swift
//  ImageFeed
//

import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - Private Properties
    private var avatarImage: UIImageView?
    private var nameLabel: UILabel?
    private var loginLabel: UILabel?
    private var descriptionLabel: UILabel?
    private var logoutButton: UIButton?
    
    private let profileService = ProfileService.shared
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAvatarImage()
        setupNameLabel()
        setupLoginLabel()
        setupDescriptionLabel()
        setupLogoutButton()
        
        if let profile = profileService.profile {
                    updateProfileData(profile: profile)
                }
    }
    
    // MARK: - Overridden Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Private Methods
    
    private func updateProfileData(profile: Profile) {
        guard let nameLabel = self.nameLabel else {return}
        nameLabel.text = profile.name
        guard let loginLabel = self.loginLabel else {return}
        loginLabel.text = profile.loginName
        guard let descriptionLabel = self.descriptionLabel else {return}
        guard let bio = profile.bio else {return}
        descriptionLabel.text = bio
    }
    
    private func setupAvatarImage() {
        let profileImage = UIImage(named: "avatar")
        
        
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
        
//        nameLabel.text = "Екатерина Новикова"
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        nameLabel.textColor = .ypWhite
        nameLabel.numberOfLines = 0
        
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
        
//        loginLabel.text = "@ekaterina_nov"
        loginLabel.font = UIFont.systemFont(ofSize: 13)
        loginLabel.textColor = .ypWhite
        loginLabel.numberOfLines = 0
        
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
        
//        descriptionLabel.text = "Hello, world!"
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
        
    }
    
}
