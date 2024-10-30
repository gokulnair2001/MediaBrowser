//
//  MediaBrowserCacheManager.swift
//  Powerplay
//
//  Created by Gokul Nair on 08/02/24.
//

import Foundation

/*
 MediaBrowserCacheManager is a local cache system which will allow MediaBrowser to caches various media in it.
 
 In order to enable MediaBrowserFileManager set the storagePolicy to to .InMemory option in MediaBrowser initialiser.
 
 The cache system allows to set number of objects to be cached, also you can toggle to evict the objects which are discarded automatically.
 */
class MediaBrowserCacheManager {
    
    static let shared = MediaBrowserCacheManager()
    
    /// Media cache store
    private let cache = NSCache<NSString, MBStorableCache>()
    
    /// Singleton class creation
    private init() {
        configureCacheSystem()
    }
    
    /// Configuring basic properties of MBCache
    private func configureCacheSystem() {
        cache.countLimit = MBConstants.Cache.countLimit
        cache.evictsObjectsWithDiscardedContent = MBConstants.Cache.evictsObjectsWithDiscardedContent
    }
    
    
    /// Used to set/add new cache into MBCache
    /// - Parameters:
    ///   - id: Unique ID for every cache
    ///   - media: media which needs to be cached
    func store(media: MBCacheable) {
        
        guard !media.cacheId.isBlank() else {
            debugPrint("MediaBrowserCacheManager: cannot store media, id is not valid")
            return
        }
        
        cache.setObject(MBStorableCache(media: media), forKey: (media.cacheId as NSString))
    }
    
    /// Used to remove cache with specified id
    /// - Parameter id: Unique id of the cache to be removed
    func removeCache(forId id: String) {
        cache.removeObject(forKey: (id as NSString))
    }
    
    /// Clears/Removes all the cache
    func disposeCache() {
        cache.removeAllObjects()
    }
    
    /// Returns the media associated with the provided id
    /// - Parameter id: Unique id of the cache
    /// - Returns: Media which is associated to the provided id
    func getCache(forId id: String) -> MBCacheable? {
        return cache.object(forKey: (id as NSString))?.media
    }
}
