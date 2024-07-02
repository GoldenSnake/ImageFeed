//
//  AuthViewControllerDelegate.swift
//  ImageFeed

import Foundation

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}
