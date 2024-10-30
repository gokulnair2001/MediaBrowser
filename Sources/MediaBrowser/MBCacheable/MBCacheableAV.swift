//
//  MBCacheableAV.swift
//  Powerplay
//
//  Created by Gokul Nair on 18/01/24.
//

import AVFoundation


// MBCacheableAV is the format in which all Audios/Videos are cached by MediaBrowser.
class MBCacheableAV: MBCacheable {
    
    var cacheId: String
    
    var rawDataFormat: String?
    
    private(set) var avAsset: AVURLAsset
    
    init(cacheId: String, avAsset: AVURLAsset) {
        self.cacheId = cacheId
        self.rawDataFormat = MediaBrowserUtils.shared.getAVFormat(url: avAsset.url)?.rawValue
        self.avAsset = avAsset
    }
    
    /// Converting raw AV data to sharable data
    func generateShareableData(completionHandler: @escaping ((Any?, MBUploadStatus, MediaManagerError?) -> ())) {
        
        guard avAsset.isExportable,
              let avFormat = MediaBrowserUtils.shared.getAVFormat(url: avAsset.url) else {
            completionHandler(nil, .Failed, .failedToGenerateSharableData(message: "No AV format exists"))
            return
        }
        
        completionHandler(nil, .Inprogress, nil)
        
        /// Temporary file creation, for storing it locally as a sharable file
        let temporaryDirectory = FileManager.default.temporaryDirectory
        let avFileURL = temporaryDirectory.appendingPathComponent("PowerPlay-\(UUID().uuidString).\(avFormat.rawValue)")
        
        /// Converting the AVAsset to AVMutableComposition
        /*This conversion is not required generally, but here when sharing AVAsset directly the operation is getting failed, thus converting it to AVMutableComposition, with basic setup in order to get it sharable*/
        let composition = AVMutableComposition()
        let compositionVideoTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
        let compositionAudioTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
        
        /// Checking if track exists or not
        guard let sourceVideoTrack = avAsset.tracks(withMediaType: AVMediaType.video).first,
              let sourceAudioTrack = avAsset.tracks(withMediaType: AVMediaType.audio).first else {
            completionHandler(nil, .Failed, .failedToGenerateSharableData(message: "Track found nil"))
            return
        }
        
        /// Inderting duration for AVMutableComposition
        do {
            try compositionVideoTrack?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: self.avAsset.duration), of: sourceVideoTrack, at: .zero)
            try compositionAudioTrack?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: self.avAsset.duration), of: sourceAudioTrack, at: .zero)
        } catch(let error) {
            completionHandler(nil, .Failed, .failedToGenerateSharableData(message: error.localizedDescription))
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
                    completionHandler(nil, .Failed, .failedToGenerateSharableData(message: exportError?.localizedDescription ?? ""))
                case .waiting, .exporting:
                    completionHandler(nil, .Inprogress, nil)
                case .completed:
                    completionHandler(avFileURL, .Completed, nil)
                default:
                    completionHandler(nil, .Failed, .failedToGenerateSharableData(message: exportError?.localizedDescription ?? ""))
                }
            }
        }
        
        
    }
}
