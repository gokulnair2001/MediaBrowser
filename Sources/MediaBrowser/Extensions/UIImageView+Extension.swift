//
//  UIImageView+Extension.swift
//  MediaBrowser
//
//  Created by Gokul Nair(Work) on 30/10/24.
//

import UIKit


public typealias ImageCompletion = ((_ image: UIImage?, _ andError: Error?) -> Void)

extension UIImageView {
    
    func loadImageURL(url: URL, contentMode: UIView.ContentMode = .center, placeHolderImage: UIImage? = nil, completion: ImageCompletion? = nil) async {
        
        self.contentMode = contentMode
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.image = placeHolderImage
        }
        
        do {
            
            let (data, _) = try await URLSession.shared.data(from: url)
            let image = UIImage(data: data)
            if #available(iOS 15.0, *) {
                /// Here on big images main thread will not be blocked
                image?.prepareForDisplay(completionHandler: { [weak self] preparedImage in
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.image = preparedImage
                        completion?(preparedImage, nil)
                    }
                })
            } else {
                /// Here on loading big images, there are chances for main thread to be getting blocked
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    let image = UIImage(data: data)
                    self.image = image
                    completion?(image, nil)
                }
            }
        
        } catch {
            completion?(nil, error)
        }
    }

}
