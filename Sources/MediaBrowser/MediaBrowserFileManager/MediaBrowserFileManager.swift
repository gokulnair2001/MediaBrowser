//
//  MediaBrowserFileManager.swift
//  Powerplay
//
//  Created by Gokul Nair on 08/02/24.
//

import UIKit
import AVFoundation

/*
 MediaBrowserFileManager is a Disk storage system which will allow MediaBrowser to store various media in it.
 
 In order to enable MediaBrowserFileManager set the storagePolicy to to .DiskStorage option in MediaBrowser initialiser.
 
 */
class MediaBrowserFileManager {
    
    static let shared = MediaBrowserFileManager()
    
    /// Singleton class creation
    private init() {
        constructMediaURL()
    }
    
    /// default fileManager instance
    private let fileManager = FileManager.default
    
    /// documentsURL instance
    private let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    
    /// user media storage URL
    private var userMediaURl: URL?
    
    /// Eviction analysis flag
    private var isEvictionCheckPerformed: Bool = false
    
    /// User media storage URL constructor
    /// - Parameter url: url which needs to be modified
    private func constructMediaURL() {
        
        guard let documentsURL else { return }
        
        if #available(iOS 16.0, *) {
            userMediaURl = documentsURL.appending(path: "Media")
        } else {
            userMediaURl = documentsURL.appendingPathComponent("Media")
        }
        
        /*
         After userMediaURl construction, its necessary to create the Media folder on the specified path, for all medias to be stored
         */
        createMediaDirectory()
    }
    
    /// Creating a media folder, to store media
    private func createMediaDirectory() {
        
        guard let userMediaURl else { return }
        
        /// Folder existence check
        if !fileManager.fileExists(atPath: userMediaURl.path) {
            
            do {
                try fileManager.createDirectory(at: userMediaURl, withIntermediateDirectories: true, attributes: nil)
            } catch {
                debugPrint("MediaBrowser, Error creating directory: \(error)")
            }
            
        } else {
            debugPrint("File already exists, no creation required")
        }
    }
}

// MARK: - Store/Save
extension MediaBrowserFileManager {
    
    /// Used to store any MBCacheable media
    /// - Parameters:
    ///   - data: MBCacheable media to be stored
    ///   - completion: session status provider with error if occurred
    func store(witheData data: MBCacheable, completion: ((MBFileOperationStatus?, MediaManagerError?) -> ())? = nil) {
        
        guard !data.cacheId.isBlank() else {
            completion?(.Failed, .failedToCacheData(message: "CacheId is blank"))
            return
        }
        
        if let toBeCachedData = data as? MBCacheableImage {
            self.store(data: toBeCachedData.image.pngData(), cacheID: data.cacheId, rawDataFormat: data.rawDataFormat, completion: completion)
            return
        }
        
        if let toBeCachedData = data as? MBCacheableDocument {
            self.store(data: toBeCachedData.document.data, cacheID: data.cacheId, rawDataFormat: data.rawDataFormat, completion: completion)
            return
        }
        
        if let toBeCachedData = data as? MBCacheableAV {
            self.store(avAsset: toBeCachedData.avAsset, cacheID: data.cacheId, completion: completion)
            return
        }
    }
    
    
    /// To store data based objects in disk
    /// - Parameters:
    ///   - data: raw data to be stored
    ///   - cacheId: unique ID for the media to be stored
    ///   - rawDataFormat: raw data format in which the media will be stored
    ///   - completion: session status provider with error if occurred
    private func store(data: Data?, cacheID: String, rawDataFormat: String?, completion: ((MBFileOperationStatus?, MediaManagerError?) -> ())? = nil) {
        
        guard let data else {
            completion?(.Failed, .failedToStoreDataInDisk(message: "No data found to store"))
            return
        }
        
        guard let fileURL = constructFileURL(withID: cacheID, rawFileExtension: rawDataFormat) else {
            completion?(.Failed, .failedToConstructFileURL(message: "RawFileExtension missing"))
            return
        }
        
        do {
            
            try data.write(to: fileURL)
            completion?(.Completed, nil)
            
        } catch let error {
            completion?(.Failed, .failedToStoreDataInDisk(message: error.localizedDescription))
            checkIfOSIsOutOfSpace(error: .systemError(error: error.localizedDescription))
        }
        
    }
    
    /// To store AVAsset based objects in disk
    /// - Parameters:
    ///   - avAsset: AVAsset to be stored
    ///   - cacheId: unique ID for the media to be stored
    ///   - rawDataFormat: raw data format in which the media will be stored
    ///   - completion: session status provider with error if occurred
    private func store(avAsset: AVURLAsset, cacheID: String, completion: ((MBFileOperationStatus?, MediaManagerError?) -> ())? = nil) {
        
        guard avAsset.isExportable else {
            completion?(.Failed, .failedToStoreDataInDisk(message: "AVAsset is not exportable"))
            return
        }
        
        guard let avFormat = MediaBrowserUtils.shared.getAVFormat(url: avAsset.url),
              let avFileURL = constructFileURL(withID: cacheID, rawFileExtension: avFormat.rawValue) else {
            completion?(.Failed, .failedToStoreDataInDisk(message: "RawFileExtension is missing"))
            return
        }
        
        completion?(.Inprogress, nil)
        
        /// Converting the AVAsset to AVMutableComposition
        /*This conversion is not required generally, but here when sharing AVAsset directly the operation is getting failed, thus converting it to AVMutableComposition, with basic setup in order to get it sharable*/
        let composition = AVMutableComposition()
        let compositionVideoTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
        let compositionAudioTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
        
        /// Checking if track exists or not
        guard let sourceVideoTrack = avAsset.tracks(withMediaType: AVMediaType.video).first,
              let sourceAudioTrack = avAsset.tracks(withMediaType: AVMediaType.audio).first else {
            completion?(.Failed, nil)
            return
        }
        
        /// Inderting duration for AVMutableComposition
        do {
            try compositionVideoTrack?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: avAsset.duration), of: sourceVideoTrack, at: .zero)
            try compositionAudioTrack?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: avAsset.duration), of: sourceAudioTrack, at: .zero)
        } catch(let error) {
            completion?(.Failed, .failedToStoreDataInDisk(message: error.localizedDescription))
            return
        }
        
        /// AVAssert Export session, which owns the responsibility to export the session
        let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetMediumQuality)
        
        exporter?.outputURL = avFileURL
        
        /// Currently we only handle MBVideoType Enum based Video formats
        exporter?.outputFileType = avFormat.outputType
        exporter?.shouldOptimizeForNetworkUse = true
        
        if let exporter {
            
            let exportStatus = exporter.status
            let exportError = exporter.error
         
            exporter.exportAsynchronously { 
                switch exportStatus {
                case .unknown, .failed, .cancelled:
                    completion?(.Failed, .failedToStoreDataInDisk(message: exportError?.localizedDescription ?? ""))
                    self.checkIfOSIsOutOfSpace(error: .systemError(error: exportError?.localizedDescription ?? ""))
                case .waiting, .exporting:
                    completion?(.Inprogress, nil)
                case .completed:
                    completion?(.Completed, nil)
                default:
                    completion?(.Failed, .failedToStoreDataInDisk(message: exportError?.localizedDescription ?? ""))
                    self.checkIfOSIsOutOfSpace(error: .systemError(error: exportError?.localizedDescription ?? ""))
                }
            }
            
        }
        
    }
}

// MARK: - GET/Retrieve
extension MediaBrowserFileManager {
    
    /// Checks if file exists for the provided url, and returns the locally store data file URL
    /// - Parameters:
    ///   - url: url for which file needs to be searched
    /// - Returns: Local File URL of provided url string
    func get(url: String) -> URL? {
        
        guard let _url = URL(string: url), UIApplication.shared.canOpenURL(_url), let userMediaURl else { return nil }
        
        let fileURL = userMediaURl.appendingPathComponent("\(_url.lastPathComponent)")
        
        if fileManager.fileExists(atPath: fileURL.path) {
            return fileURL.absoluteURL
        }
        
        return nil
    }
    
    /// Checks if file exists for the provided url, and returns the locally store data
    /// - Parameter fileUrl: url for which file needs to be searched
    /// - Returns: Local File data of provided url 
    func get(fileUrl: URL) -> Data? {
        
        if fileUrl.startAccessingSecurityScopedResource(), fileManager.fileExists(atPath: fileUrl.path) {
            
            defer { fileUrl.stopAccessingSecurityScopedResource() }
            
            do {
                
                return try Data(contentsOf: fileUrl)
                
            } catch {
                
                debugPrint("MediaBrowser: FileURL data extraction failed")
                return nil
            }
            
        }
        
        debugPrint("MediaBrowser: File path doesn't exist")
        return nil
    }
}

// MARK: - Delete
extension MediaBrowserFileManager {
    
    /* The below method is not Used currently */
    /// Deletes the locally stored file, for provide data
    /// - Parameters:
    ///   - data: cache to be cleared
    ///   - completion: delete session status provide, with error if occurred
    private func delete(withData data: MBCacheable, completion: ((MBFileOperationStatus?, MediaManagerError?) -> ())? = nil) {
        
        guard let fileURL = constructFileURL(withID: data.cacheId, rawFileExtension: data.rawDataFormat) else {
            completion?(.Failed, .failedToConstructFileURL(message: "RawFileExtension is missing"))
            return
        }
        
        do {
            
            try fileManager.removeItem(at: fileURL)
            completion?(.Completed, nil)
            
        } catch {
            
            completion?(.Failed, .failedToDeleteDataFromDisk(message: error.localizedDescription))
            
        }
        
    }
    
    /// Disposes the whole media directory
    /// - Parameter completion: delete session status provide, with error if occurred
    func disposeDirectory(completion: ((MBFileOperationStatus?, MediaManagerError?) -> ())? = nil) {
        
        guard let userMediaURl else {
            completion?(.Failed, .failedToDisposeDirectory(message: "Media URL is missing"))
            return
        }
        
        do {
            try fileManager.removeItem(at: userMediaURl)
            completion?(.Completed, nil)
            
        } catch {
            
            completion?(.Failed, .failedToDisposeDirectory(message: error.localizedDescription))
            checkIfOSIsOutOfSpace(error: .systemError(error: error.localizedDescription))
            
        }
        
    }
}

// MARK: - Eviction Check
extension MediaBrowserFileManager {
    
    /* Performs eviction of Media folder if the current folder size is more than the set limit */
    func checkForEviction() {
        
        if !isEvictionCheckPerformed {
            
            guard let size = getMediaFolderSize() else { return }
            
            /// By default set limit is 0, thus no eviction process will be initiated by Media Browser
            if (size > MBConstants.DiskStorage.maxSize) && (MBConstants.DiskStorage.maxSize > 0) {
                
                self.disposeDirectory { [weak self] (status, error) in
                    /// On deletion is completed, set flag to true
                    if status == .Completed {
                        self?.isEvictionCheckPerformed = true
                    }
                }
                
            }
            
        }
        
    }
    
    /// Check for OS Space error
    /// - Parameter error: error thrown while performing operations on file
    private func checkIfOSIsOutOfSpace(error: MediaManagerError) {
        
        let _error = error as NSError
        
        if _error.domain == NSCocoaErrorDomain && _error.code == NSFileWriteOutOfSpaceError {
            self.isEvictionCheckPerformed = false
        }
        
    }
    
    private func getMediaFolderSize() -> UInt64? {
        
        var folderSize: UInt64 = 0
        
        guard let userMediaURl, let files = fileManager.enumerator(atPath: userMediaURl.path) else {
            return nil
        }
        
        for case let file as String in files {
            
            let filePath = "\(userMediaURl.path)/\(file)"
            
            var isDirectory: ObjCBool = false
            
            guard fileManager.fileExists(atPath: filePath, isDirectory: &isDirectory) else {
                continue
            }
            
            if !isDirectory.boolValue {
                do {
                    let attributes = try fileManager.attributesOfItem(atPath: filePath)
                    if let fileSize = attributes[.size] as? UInt64 {
                        folderSize += fileSize
                    }
                } catch {
                    debugPrint("MediaBrowserFileManager, file size calculation failed with: \(error)")
                }
            }
        }
        
        let sizeInMB = folderSize/(1024*1024)
        
        return sizeInMB
    }
}

// MARK: - Utility methods
extension MediaBrowserFileManager {
    /**
     Since there are two type of URL which can be formed,
     * Regular URL based, where online URL last Path Component is used as file name
     * Explicit ID based, where provided ID is used as file name
     
     Raw format is asked explicitly, to avoid extension less storage, else this might lead to multiple files with same ID
     */
    /// File URL constructor
    /// - Parameters:
    ///   - cacheID: provided cache ID
    ///   - rawFileExtension: extension in which file needs to be stored
    /// - Returns: constructed file url
    private func constructFileURL(withID cacheID: String, rawFileExtension: String?) -> URL? {
        
        guard let userMediaURl else { return nil }
        
        if let url = URL(string: cacheID), UIApplication.shared.canOpenURL(url) {
            
            return userMediaURl.appendingPathComponent("\(url.lastPathComponent)")
            
        } else {
            
            guard let rawFileExtension else {
                debugPrint("MediaBrowserFileManager, rawFileExtension missing")
                return nil
            }
            
            return userMediaURl.appendingPathComponent("\(cacheID).\(rawFileExtension)")
            
        }
        
    }
}
