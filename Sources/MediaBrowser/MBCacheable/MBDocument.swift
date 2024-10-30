//
//  MBCacheableDocument.swift
//  Powerplay
//
//  Created by Gokul Nair on 07/02/24.
//

import Foundation

struct MBDocument {
    var data: Data
    var fileExtension: String
}

// MBCacheableDocument is the format in which all docs are cached by MediaBrowser.
class MBCacheableDocument: MBCacheable {
    
    var cacheId: String
    
    var rawDataFormat: String?
    
    private(set) var document: MBDocument
    
    init(cacheId: String, document: MBDocument) {
        self.cacheId = cacheId
        self.rawDataFormat = document.fileExtension
        self.document = document
    }
    
    func generateShareableData(completionHandler: @escaping ((Any?, MBUploadStatus, MediaManagerError?) -> ())) {
        
        completionHandler(nil, .Inprogress, nil)
        
        let temporaryDirectory = FileManager.default.temporaryDirectory
        let documentFileURL = temporaryDirectory.appendingPathComponent("PowerPlay-\(UUID().uuidString).\(document.fileExtension)")
        
        do {
            
            try document.data.write(to: documentFileURL)
            completionHandler(documentFileURL, .Completed, nil)
            
        } catch let error {
            
            completionHandler(nil, .Failed, .failedToGenerateSharableData(message: error.localizedDescription))
        }
    }
}
