//
//  WebViewViewController.swift
//  ImageFeed
//

import UIKit
import WebKit

final class WebViewViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet private var webView: WKWebView!
    @IBOutlet private var progressView: UIProgressView!
    
    // MARK: - Public Properties
     weak var delegate: WebViewViewControllerDelegate?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateProgress()
        loadWebView()
        setNeedsStatusBarAppearanceUpdate()
        webView.navigationDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        webView.addObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            options: .new,
            context: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), context: nil)
    }
    
    // MARK: - Overridden Methods
    
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            updateProgress()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
          return .default
      }

    // MARK: - Private Methods
    
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
    
}

// MARK: - WKNavigationDelegate

extension WebViewViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let code = fetchCode(from: navigationAction) {
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
            print(request)
            webView.load(request)
        } else {
            print("Error to load request")
            return
        }
    }
    
    private func fetchCode(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}
