//
//  AuthNavigationController.swift
//  ImageFeed
//
import UIKit

final class AuthNavigationController: UINavigationController {
    
    override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
    
}
