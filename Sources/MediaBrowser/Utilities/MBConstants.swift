//
//  MediaBrowserConstants.swift
//  Powerplay
//
//  Created by Gokul Nair on 31/01/24.
//

import UIKit


public struct MBConstants {
    
    public struct Images {
        
        /// Images for error occurrence
        public static var videoBrowserErrorImage: String = "error_noNetwork"
        public static var pdfBrowserErrorImage: String = "error_noNetwork"
        public static var photoBrowserErrorImage: String = "error_noNetwork" /// Used as placeholder image if not set explicitly
        public static var webBrowserErrorImage: String = "error_noNetwork"
        
    }
    
    public struct Color {
        /// Browser Tint Color
        public static var browserTint: UIColor = .white
        public static var loaderTint: UIColor = .gray
    }
    
    public struct Cache {
        public static var countLimit: Int = 10
        public static var evictsObjectsWithDiscardedContent: Bool = true
    }
    
    public struct DiskStorage {
        /// This size will be considered in MB
        static var maxSize: UInt64 = 0
    }
    
    public struct UITexts {
        public static var photoBrowserErrorText: String = "Image Download failed"
        public static var videoBrowserErrorText: String = "Video Download failed"
        public static var documentBrowserErrorText: String = "Document Download failed"
        public static var webBrowserErrorText: String = "Website failed to load"
        public static var errorActionButtonText: String = "Retry"
    }
    
    public struct Metrics {
        public static var homeViewAppBarHeight: CGFloat = 55
    }
    
    public static var isPhotoZoomEnabled: Bool = true
}
