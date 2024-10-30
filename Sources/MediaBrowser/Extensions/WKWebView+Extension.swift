//
//  WKWebView+Extension.swift
//  MediaBrowser
//
//  Created by Gokul Nair(Work) on 30/10/24.
//


import WebKit


extension WKWebView {
    
    func load(_ urlString: String) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            load(request)
        }
    }
    
}
