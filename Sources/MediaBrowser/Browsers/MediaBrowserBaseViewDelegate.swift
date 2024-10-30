//
//  MediaBrowserBaseViewDelegate.swift
//  Powerplay
//
//  Created by Gokul Nair on 22/01/24.
//

import Foundation


protocol MediaBrowserBaseViewDelegate: AnyObject {
    
    /**
     Tells the delegate that the media rendering is finished
     
         - Parameter index: the index of the current browser
         - Parameter cachedData: Cached data of existing browser media
         - Parameter isCachingRequired: Caching mechanism trigger
     */
    func didFinishRenderingMedia(withIndexPath index: Int, cachedData: MBCacheable?, isCachingRequired: Bool)
    
    
    /**
     Tells the delegate that the media rendering is failed
     
         - Parameter index: the index of the current browser
     */
    func didFailRenderingMedia(withIndexPath index: Int, error: MediaManagerError)
}
