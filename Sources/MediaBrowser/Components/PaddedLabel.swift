//
//  PaddedLabel.swift
//  MediaBrowser
//
//  Created by Gokul Nair(Work) on 30/10/24.
//


import UIKit


// A custom UILabel subclass that adds padding around the text, allowing you to specify custom insets for finer control over the label's appearance.
class PaddedLabel: UILabel {
    
    // Padding to apply around the label's text
    var padding: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    
    // Convenience initializer to set custom padding
    convenience init(padding: UIEdgeInsets) {
        self.init(frame: .zero)
        self.padding = padding
    }
    
    // Overrides the drawText method to add padding around the text
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: padding.top, left: padding.left, bottom: padding.bottom, right: padding.right)
        super.drawText(in: rect.inset(by: insets))
    }
    
    // Adjusts the intrinsic content size to include the padding
    override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height += padding.top + padding.bottom
        contentSize.width += padding.left + padding.right
        return contentSize
    }
}
