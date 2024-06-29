//
//  WebViewViewController.swift
//  ImageFeed
//

import UIKit
import WebKit

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController {
    
    @IBOutlet private var webView: WKWebView!
    
     weak var delegate: WebViewViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadWebView()
        
        webView.navigationDelegate = self
    }
}

// MARK: - WKNavigationDelegate

extension WebViewViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let code = fetchCode(from: navigationAction.request.url) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}

// MARK: - loadWebView

private extension WebViewViewController {
    func loadWebView() {
        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize")
        urlComponents?.queryItems = [URLQueryItem(name: "client_id", value: Constants.accessKey),
                                     URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
                                     URLQueryItem(name: "response_type", value: "code"),
                                     URLQueryItem(name: "scope", value: Constants.accessScope)]
        
        if let url = urlComponents?.url{
            let request = URLRequest(url: url)
            webView.load(request)
        } else {
            print("Error")
            return
        }
    }
    
    private func fetchCode(from url: URL?) -> String? {
        guard let url = url,
              let urlComponents = URLComponents(string: url.absoluteString),
              urlComponents.path == "/oauth/authorize/native",
              let item = urlComponents.queryItems?.first(where: { $0.name == "code"})
        else { return nil }
        
        return item.value
    }
}
