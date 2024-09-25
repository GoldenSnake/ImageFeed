//
//  TabBarController.swift
//  ImageFeed
//

import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let imagesListViewController = storyboard.instantiateViewController(
                    withIdentifier: "ImagesListViewController") as! ImagesListViewController
                imagesListViewController.configure(ImagesListPresenter())
        
        let profileViewController = ProfileViewController()
        let profilePresenter = ProfilePresenter()
        profileViewController.presenter = profilePresenter
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
        profilePresenter.view = profileViewController
        
        self.viewControllers = [imagesListViewController, profileViewController]
        
        let appearance = UITabBarAppearance()
                appearance.backgroundColor = .ypBlack
                tabBar.standardAppearance = appearance
                tabBar.tintColor = .ypWhite
    }
    
}
