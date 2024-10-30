//
//  MediaBrowserConstants.swift
//  Powerplay
//
//  Created by Gokul Nair on 31/01/24.
//

import UIKit


struct MBConstants {
    
    struct Images {
        
        /// Images for error occurrence
        static var videoBrowserErrorImage: String = "error_noNetwork"
        static var pdfBrowserErrorImage: String = "error_noNetwork"
        static var photoBrowserErrorImage: String = "error_noNetwork" /// Used as placeholder image if not set explicitly
        static var webBrowserErrorImage: String = "error_noNetwork"
        
    }
    
    struct Color {
        /// Browser Tint Color
        static var browserTint: UIColor = .white
        static var loaderTint: UIColor = .gray
    }
    
    struct Cache {
        static var countLimit: Int = 10
        static var evictsObjectsWithDiscardedContent: Bool = true
    }
    
    struct DiskStorage {
        /// This size will be considered in MB
        static var maxSize: UInt64 = 0
    }
    
    struct UITexts {
        static var photoBrowserErrorText: String = "Image Download failed"
        static var videoBrowserErrorText: String = "Video Download failed"
        static var documentBrowserErrorText: String = "Document Download failed"
        static var webBrowserErrorText: String = "Website failed to load"
        static var errorActionButtonText: String = "Retry"
    }
    
    static var isPhotoZoomEnabled: Bool = true
}
