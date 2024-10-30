//
//  UIViewController+Extension.swift
//  MediaBrowser
//
//  Created by Gokul Nair(Work) on 30/10/24.
//

import UIKit


extension UIViewController {
    
    var className: String {
        return String(describing: type(of: self))
    }
    
}
