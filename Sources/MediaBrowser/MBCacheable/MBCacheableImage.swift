//
//  MBCacheableImage.swift
//  Powerplay
//
//  Created by Gokul Nair on 18/01/24.
//

import UIKit

// MBCacheableImage is the format in which all Images are cached by MediaBrowser.
class MBCacheableImage: MBCacheable {
    
    var cacheId: String
    
    var rawDataFormat: String?
    
    private(set) var image: UIImage
    
    init(cacheId: String, image: UIImage) {
        self.cacheId = cacheId
        self.rawDataFormat = image.imageType?.rawValue ?? "jpeg"
        self.image = image
    }
    
    /// Converting raw image data to sharable data
    func generateShareableData(completionHandler: @escaping ((Any?, MBUploadStatus, MediaManagerError?) -> ())) {
        
        completionHandler(nil, .Inprogress, nil)
        
        let temporaryDirectory = FileManager.default.temporaryDirectory
        let imageFileURL = temporaryDirectory.appendingPathComponent("PowerPlay-\(UUID().uuidString).jpeg")
        do {
            try image.jpegData(compressionQuality: 1.0)?.write(to: imageFileURL)
            completionHandler(imageFileURL, .Completed, nil)
            
        } catch let error {
            completionHandler(nil, .Failed, .failedToGenerateSharableData(message: error.localizedDescription))
        }
        
    }
}
