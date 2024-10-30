//
//  PaddedLabel.swift
//  MediaBrowser
//
//  Created by Gokul Nair(Work) on 30/10/24.
//


import UIKit

class PaddedLabel: UILabel {
    
    var padding: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    
    convenience init(padding: UIEdgeInsets) {
        self.init(frame: .zero)
        self.padding = padding
    }
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: padding.top, left: padding.left, bottom: padding.bottom, right: padding.right)
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        get {
            var contentSize = super.intrinsicContentSize
            contentSize.height += padding.top + padding.bottom
            contentSize.width += padding.left + padding.right
            return contentSize
        }
    }
    
}
