//
//  MBStorableCache.swift
//  Powerplay
//
//  Created by Gokul Nair on 08/02/24.
//

import Foundation


final class MBStorableCache: NSObject {
    
    let media: MBCacheable

    init(media: MBCacheable) {
        self.media = media
    }
}
