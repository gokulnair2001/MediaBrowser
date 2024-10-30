//
//  ErrorContentModel.swift
//  Powerplay
//
//  Created by Gokul Nair on 01/10/22.
//

import UIKit

// MARK: - Error Content Model

struct ErrorViewContent {
    var errorContent: ErrorContent
    var error: ErrorType?
    var properties: ErrorProperties
}

struct ErrorContent {
    var actionTitle: String?
    var title: String?
    var image: String
    var uiImage: UIImage? = nil
    var attributedTitle: NSAttributedString?
}

struct ErrorProperties {
    var url: String?
    var appSection: String
}

enum ErrorType: Int {
    case _500 = 500
    case _502 = 502
    case _504 = 504
    case noNetwork = -1009
    case defaultError = 002 // Onboarding Error screens
    
   
    // Title for error screen label
    var title: String {
        switch self {
        case .noNetwork:
            return "No Network"
        case ._500, ._502, ._504, .defaultError:
            return "Something went wrong"
        }
    }
    
    var image: UIImage? {
        switch self {
        case ._500:
            return UIImage(named: "error_500")
        case ._502:
            return UIImage(named: "error_502")
        case ._504:
            return UIImage(named: "error_504")
        case .noNetwork:
            return UIImage(named: "error_noNetwork")
        case .defaultError:
            return UIImage(named: "error_502")
        }
    }
    
}
