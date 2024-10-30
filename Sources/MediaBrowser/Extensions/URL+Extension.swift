//
//  URL+Extension.swift
//  MediaBrowser
//
//  Created by Gokul Nair(Work) on 30/10/24.
//


import UIKit
import MobileCoreServices


extension URL {
    
    var mimeType: String {
        get{
            let url = NSURL(fileURLWithPath: self.path)
            let pathExtension = url.pathExtension
            
            if let uti = UTTypeCreatePreferredIdentifierForTag(
                kUTTagClassFilenameExtension,
                pathExtension! as NSString,
                nil
            )?.takeRetainedValue() {
                if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                    return mimetype as String
                }
            }
            return "application/octet-stream"
        }
    }
}
