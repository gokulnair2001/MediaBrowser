//
//  MediaManagerError.swift
//  Powerplay
//
//  Created by Gokul Nair(Work) on 17/07/24.
//

import Foundation


/// Media Manager errors
enum MediaManagerError: Error {
    
    /// Browser data rendering failed
    case failedToRenderBrowserData(message: String)
    
    /// Media sharing failed
    case failedToGenerateSharableData(message: String)
    
    /// Disk folder/file url creation error
    case failedToConstructFileURL(message: String)
    
    /// Browser data caching error
    case failedToCacheData(message: String)
    
    /// InDisk storage error
    case failedToStoreDataInDisk(message: String)
    
    /// InDisk data deletion error
    case failedToDeleteDataFromDisk(message: String)
    
    /// Disk folder calculation error
    case failedToCalculateFileSize
    
    /// Disposing directory failed
    case failedToDisposeDirectory(message: String)
    
    /// Generic System Error
    case systemError(error: String)
    
    var errorMessage: String {
        switch self {
        case .failedToRenderBrowserData(let message):
            return message
        case .failedToGenerateSharableData(let message):
            return message
        case .failedToConstructFileURL(let message):
            return message
        case .failedToCacheData(let message):
            return message
        case .failedToStoreDataInDisk(let message):
            return message
        case .failedToDeleteDataFromDisk:
            return "Failed to Delete data from Disk"
        case .failedToCalculateFileSize:
            return "Failed to calculate file size"
        case .failedToDisposeDirectory(let message):
            return message
        case .systemError(let message):
            return message
        }
    }
}
