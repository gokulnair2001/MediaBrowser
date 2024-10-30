//
//  MBCacheableWeb.swift
//  Powerplay
//
//  Created by Gokul Nair on 08/02/24.
//

import Foundation

struct MBWeb {
    
    var data: Data
    var url: URL
}

// MBCacheableWeb is the format in which all web views are cached by MediaBrowser.
class MBCacheableWeb: MBCacheable {
    
    var cacheId: String
    
    var rawDataFormat: String?
    
    private(set) var web: MBWeb
    
    init(web: MBWeb) {
        self.web = web
        self.cacheId = "\(web.url)"
    }
    
    func generateShareableData(completionHandler: @escaping ((Any?, MBUploadStatus, MediaManagerError?) -> ())) {
        completionHandler(web.url, .Completed, nil)
    }
}
