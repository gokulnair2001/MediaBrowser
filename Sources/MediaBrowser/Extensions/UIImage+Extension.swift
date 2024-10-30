//
//  UIImage+Extension.swift
//  MediaBrowser
//
//  Created by Gokul Nair(Work) on 30/10/24.
//

import UIKit

extension UIImage {
    
    enum ImageFormat: String {
        case jpeg = "jpeg"
        case png = "png"
    }
    
    var imageType: ImageFormat? {
        
        guard let data = self.pngData() else { return nil }
        
        var values = [UInt8](repeating: 0, count: 1)
        data.copyBytes(to: &values, count: 1)
        
        switch values[0] {
        case 0xFF:
            return .jpeg
        case 0x89:
            return .png
        default:
            return nil
        }
    }

}
