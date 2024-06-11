//
//  WebViewViewController.swift
//  ImageFeed
//

import UIKit
import WebKit

class WebViewViewController: UIViewController {
    
    @IBOutlet private var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadWebView()
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
}
