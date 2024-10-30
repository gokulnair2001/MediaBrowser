//
//  MediaBrowserData.swift
//  Powerplay
//
//  Created by Gokul Nair on 18/01/24.
//

import UIKit

// MediaBrowserData holds the necessary information which every browser requires to render any form of MediaBrowsable Data
struct MediaBrowserData {
    
    var id = UUID().uuidString
    var mediaType: MBMediaType?
    var placeHolder: UIImage? = nil
    var cachedData: MBCacheable?  // Cached Media
    
    mutating func set(cachedData: MBCacheable?) {
        self.cachedData = cachedData
    }
}
