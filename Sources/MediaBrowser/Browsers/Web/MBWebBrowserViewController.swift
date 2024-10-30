//
//  MBWebBrowserViewController.swift
//  Powerplay
//
//  Created by Gokul Nair on 07/02/24.
//

import UIKit
import WebKit

/*
 Web based browsing is done on this browser.
 
 MediaBrowser checks for the URL type, if the type belong any form of web hosted file then the respective browser is used else all the URLs are browsed in this browser
 */
class MBWebBrowserViewController: MBBrowserBaseViewController {
    
    private(set) var webView: WKWebView?
    
    override init(url: URL?, placeHolder: UIImage?, localMediaCache: MBCacheable?, storagePolicy: MBStoragePolicy) {
        super.init(url: url, placeHolder: placeHolder, localMediaCache: localMediaCache, storagePolicy: storagePolicy)
        
        configureWebView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let mediaUrl {
            checkIfPreCached(url: mediaUrl)
        }
    }
    
    override func addViews() {
        
        guard let webView else { return }
        
        self.view.addSubview(webView)
    }
    
    override func layoutConstraints() {
        
        guard let webView else { return }
        
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
    }
    
    private func configureWebView() {
        
        let webViewConfiguration = WKWebViewConfiguration()
        
        webView = WKWebView(frame: .zero, configuration: webViewConfiguration)
        webView?.scrollView.isScrollEnabled = true
        webView?.navigationDelegate = self
        webView?.translatesAutoresizingMaskIntoConstraints = false
        webView?.scrollView.isMultipleTouchEnabled = false
        webView?.scrollView.bouncesZoom = false
        webView?.translatesAutoresizingMaskIntoConstraints = false
        webView?.isUserInteractionEnabled = true
        webView?.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.102 Safari/537.36"
        
    }
    
    /// Checks for PreCached data, and if preCached data exists then consumes it if not then network calls are made to render the data
    func checkIfPreCached(url: URL) {
        
        if let localMediaCache, let cachedData = localMediaCache as? MBCacheableWeb {
            
            self.webView?.load(cachedData.web.data, mimeType: "application/x-webarchive", characterEncodingName: "utf-8", baseURL: url)
            
        } else {
            
            loader.startLoading()
            webView?.load("\(url)")
            
        }
        
    }
    
    /// Error View Action
    override func didTapOnAction(errorType: ErrorType) {
        if let mediaUrl {
            loader.startLoading()
            webView?.load("\(mediaUrl)")
        }
    }
}
// MARK: - WKNavigationDelegate
extension MBWebBrowserViewController: WKNavigationDelegate {
    
    /// After URL rendering, webView is archived to store in cache
    @objc func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        /// Safety check
        self.hideErrorSheet()
        
        loader.stopLoading()
        
        guard localMediaCache == nil else { return }
        
        if #available(iOS 14.0, *) {
            
            webView.createWebArchiveData { [weak self] response in
                
                guard let self else { return }
                
                switch response {
                case .success(let data):
                    if let mediaUrl {
                        let cacheToStore = MBCacheableWeb(web: MBWeb(data: data, url: mediaUrl))
                        self.localMediaCache = cacheToStore
                        self.delegate?.didFinishRenderingMedia(withIndexPath: self.browserIndex, cachedData: cacheToStore, isCachingRequired: true)
                    }
                    break
                case .failure(let error):
                    self.delegate?.didFailRenderingMedia(withIndexPath: self.browserIndex, error: .failedToRenderBrowserData(message: error.localizedDescription))
                    break
                }
                
            }
        } else {
            /// No Caching will occur
        }
        
    }
    
    @objc func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
        debugPrint("MediaBrowser Web loading issue: \(error.localizedDescription)")
        
        handleError(content: .init(errorContent: .init(actionTitle: MBConstants.UITexts.errorActionButtonText, title: MBConstants.UITexts.webBrowserErrorText, image: MBConstants.Images.webBrowserErrorImage), properties: .init(appSection: className)))
    }
    
}
