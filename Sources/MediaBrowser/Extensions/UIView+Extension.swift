//
//  UIView+Extension.swift
//  MediaBrowser
//
//  Created by Gokul Nair(Work) on 30/10/24.
//

import UIKit


extension UIView {
    
    @discardableResult
    func fromNib() -> UIView?{
        
        let nibName = String(describing: Self.self)
        guard let contentView = Bundle.main.loadNibNamed(nibName, owner: self)?.first as? UIView else { return nil }
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(contentView)
        return contentView
    }
    
}
