//
//  ErrorRepresentable.swift
//  Powerplay
//
//  Created by Gokul Nair on 01/10/22.
//

import Foundation
import UIKit

/// Error content delegate
protocol ErrorViewRepresentable: AnyObject {
    
    var errorView: MBErrorView { get }
    var parentView: UIView { get }
    var isTabBarVisible: Bool { get }
    
    func didTapOnAction(errorType: ErrorType)
}

extension ErrorViewRepresentable where Self: UIViewController {
    
    var isTabBarVisible: Bool {
        return false
    }
    
    /// Handel Error on representable screens
    func handleError(content: ErrorViewContent) {
        DispatchQueue.main.async { [weak self] in
            
            guard let self else { return }
            self.parentView.addSubview(self.errorView)
            self.addConstraints()
            self.errorView.showErrorScreen(content: content)
        }

    }
    
    func addConstraints(){
        
        NSLayoutConstraint.activate([
            errorView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: errorView.insets.left),
            errorView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -errorView.insets.right),
            errorView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: errorView.insets.top),
            errorView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -errorView.insets.bottom)
        ])
    
    }
    
    /// Hides error from representable screens
    func hideErrorSheet() {
        DispatchQueue.main.async { [weak self] in
            self?.errorView.hideErrorScreen()
        }
    }
    
    func didTapOnAction(errorType: ErrorType) {
        // needs to be implemented when in use
    }
    
}
