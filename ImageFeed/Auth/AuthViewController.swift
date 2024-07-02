//
//  AuthViewController.swift
//  ImageFeed
//

import UIKit

final class AuthViewController: UIViewController {
    
    // MARK: - Public Properties
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: - Private Properties
    private let showWebViewSegueIdentifier = "ShowWebView"
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
    }
    
    // MARK: - Overridden Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Invalid segue destination for ID: \(showWebViewSegueIdentifier)")
                return
            }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    //MARK: - Private Methods
    
    @objc
    private func loginButtonDidTap() {
        performSegue(withIdentifier: showWebViewSegueIdentifier, sender: nil)
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black")
    }
    
}

//MARK: - WebViewViewControllerDelegate

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        OAuth2Service.shared.fetchOAuthToken(with: code) { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success:
                        self.delegate?.didAuthenticate(self)
                    case .failure(let error):
                        navigationController?.popViewController(animated: true)
                        print(errorMessage(from: error))
                    }
                }
        print("CODE: \(code)")
    }
    
    func errorMessage(from error: Error) -> String {
            switch error {
            case NetworkError.httpStatusCode(let code):
                return "Error \(code) when receiving token."
            default:
                return error.localizedDescription
            }
        }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}
