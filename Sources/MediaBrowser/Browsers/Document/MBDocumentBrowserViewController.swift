//
//  MBDocumentBrowserViewController.swift
//  Powerplay
//
//  Created by Gokul Nair on 08/02/24.
//

import UIKit
import WebKit

/*
 For all the Document based browsing following browser is used.
 
 This browser caches the rendered data in MBCacheableDocument instead of MBCacheableWeb format, to share the rendered file in respective doc format.
 */
final class MBDocumentBrowserViewController: MBWebBrowserViewController {
    
    /// On error action
    override func didTapOnAction(errorType: ErrorType) {
        if let mediaUrl {
            checkIfPreCached(url: mediaUrl)
        }
    }
    
    /// Checks for PreCached data, and if preCached data exists then consumes it if not then network calls are made to render the data
    override func checkIfPreCached(url: URL) {
        
        if let localMediaCache, let cachedData = localMediaCache as? MBCacheableDocument {
            
            self.webView?.load(cachedData.document.data, mimeType: url.mimeType, characterEncodingName: "utf-8", baseURL: url)
            
        } else {
            
            self.loader.startLoading()
            
            MediaBrowserUtils.shared.fetchURLData(url: url) { [weak self] data, error in
                
                self?.loader.stopLoading()
                
                guard let self else { return }
                
                if let data {
                    
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.webView?.load(data, mimeType: url.mimeType, characterEncodingName: "utf-8", baseURL: url)
                    }
                    
                    let cacheToStore = MBCacheableDocument(cacheId: "\(url)", document: MBDocument(data: data, fileExtension: url.pathExtension))
                    self.localMediaCache = cacheToStore
                    /// If file URL, then no need of caching
                    self.delegate?.didFinishRenderingMedia(withIndexPath: self.browserIndex, cachedData: cacheToStore, isCachingRequired: !url.isFileURL)
                    
                }
                
                if let error {
                    
                    self.delegate?.didFailRenderingMedia(withIndexPath: self.browserIndex, error: .failedToRenderBrowserData(message: error.localizedDescription))
                    
                    self.showErrorScreen()
                }
            }
            
        }
        
    }
    
    override func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.hideErrorSheet()
    }
    
    override func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
        debugPrint("MediaBrowser Document loading issue: \(error.localizedDescription)")
        
        self.showErrorScreen()
    }
    
    private func showErrorScreen() {
        
        handleError(content: .init(errorContent: .init(actionTitle: MBConstants.UITexts.errorActionButtonText, title: MBConstants.UITexts.documentBrowserErrorText, image: MBConstants.Images.webBrowserErrorImage), properties: .init(appSection: self.className)))
        
    }
}
