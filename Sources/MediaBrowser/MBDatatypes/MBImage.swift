//
//  MBImage.swift
//  Powerplay
//
//  Created by Gokul Nair on 17/01/24.
//

import UIKit


// MBImage is the Image format which MediaBrowser uses to render Image based media.
class MBImage: MediaBrowsable {
    
    var image: UIImage
    
    var mediaId: String?
    
    var placeHolderImage: UIImage?
    
    init(id: String?, image: UIImage, placeHolderImage: UIImage? = UIImage()) {
        self.image = image
        self.mediaId = id
        self.placeHolderImage = placeHolderImage
    }
    
    /// Transforms the MediaBrowsable data to MBMediaType
    func transformToBrowsableMedia() -> MBMediaType? {
        return  .Image(image: image)
    }
}

