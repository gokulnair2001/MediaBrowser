//
//  MBCacheable.swift
//  Powerplay
//
//  Created by Gokul Nair on 18/01/24.
//

import Foundation

// MBCacheable is the generic format which every Data type needs in order to be cached. 
protocol MBCacheable {
    
    /**
     For caching a media, it requires a unique ID, to store the data. Providing a unique cacheId is important to perform proper caching.
     */
    var cacheId: String { get }
    
    /**
     For caching a media in Disk, raw format of the data is required. This raw format is used to preserve the data in its original format.
     */
    var rawDataFormat: String? { get }
    
    /**
     Cached data are used for Share purpose, this method generates sharable data format from cached data
     
     - Parameter completionHandler: Handler which delegates the updated Shareable data, UploadStatus and error
     */
    func generateShareableData(completionHandler: @escaping((Any?, MBUploadStatus, MediaManagerError?) -> ()))
}
