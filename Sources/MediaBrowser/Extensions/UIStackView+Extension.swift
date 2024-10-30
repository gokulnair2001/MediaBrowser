//
//  UIStackView+Extension.swift
//  MediaBrowser
//
//  Created by Gokul Nair(Work) on 30/10/24.
//

import UIKit


extension UIStackView {
    
    public func addArrangedSubViews(_ views: [UIView]?){
        views?.forEach{ self.addArrangedSubview($0) }
    }
    
}
