//
//  MBVideoBrowserViewController.swift
//  Powerplay
//
//  Created by Gokul Nair on 12/01/24.
//

import UIKit
import AVFoundation

/*
 Audio/Video based medias browsing is done by this browser.
 */
final class MBVideoBrowserViewController: MBBrowserBaseViewController {
    
    private lazy var videoPlayerView: CVPlayerViewController = {
        let view = CVPlayerViewController(url: nil, isAutoPlay: false)
        view.delegate = self
        return view
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkIfPreCached()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addViews()
        layoutConstraints()
        addTarget()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        videoPlayerView.playerView.pause()
        videoPlayerView.didTapPause()
        
    }
    
    override func addViews() {
        self.view.addSubview(videoPlayerView.view)
    }
    
    override func layoutConstraints() {
        
        NSLayoutConstraint.activate([
            videoPlayerView.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            videoPlayerView.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            videoPlayerView.view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            videoPlayerView.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    override func addTarget() {
        
    }
    
    override func getErrorRepresentableView() -> UIView {
        return self.videoPlayerView.view
    }
    
    /// Checks for PreCached data, and if preCached data exists then consumes it if not then network calls are made to render the data
    private func checkIfPreCached() {
        
        if let localMediaCache, let cachedAV = localMediaCache as? MBCacheableAV {
            
            self.preloadAsset(asset: cachedAV.avAsset)
            
        } else {
            
            self.videoPlayerView.url = nil
            self.videoPlayerView.url = mediaUrl
            
        }
        
        self.videoPlayerView.didPaused()
    }
    
    func preloadAsset(asset: AVURLAsset) {
        
        // Properties of the AVAsset that you want to load asynchronously.
        let assetKeys = ["playable", "hasProtectedContent", "tracks"]
        
        asset.loadValuesAsynchronously(forKeys: assetKeys) { [weak self] in
            
            guard let self else { return }
            
            // Check if the values have been loaded successfully
            var error: NSError?
            for key in assetKeys {
                let status = asset.statusOfValue(forKey: key, error: &error)
                switch status {
                case .loading, .unknown:
                    return
                case .loaded:
                    self.hideErrorSheet()
                    self.videoPlayerView.playerView.playWithAVItemAsset(assets: asset)
                    return
                case .failed, .cancelled:
                    debugPrint("MediaBrowser - Failed to preload \(key): \(error?.localizedDescription ?? "Unknown error")")
                    self.handleError(content: .init(errorContent: .init(actionTitle: MBConstants.UITexts.errorActionButtonText, title: MBConstants.UITexts.videoBrowserErrorText, image: MBConstants.Images.videoBrowserErrorImage, uiImage: self.placeHolder), properties: .init(appSection: className)))
                    return
                @unknown default:
                    return
                }
            }
        }
    }
    
    override func didTapOnAction(errorType: ErrorType) {
        checkIfPreCached()
    }
}

// MARK: - CVPlayerViewControllerDelegate
extension MBVideoBrowserViewController: CVPlayerViewControllerDelegate {
    
    func didReadyToPlay() {
        
        /// If view visible then play
        if self.view.window != nil {
            videoPlayerView.playerView.play()
            videoPlayerView.didTapPlay()
        } else {
            videoPlayerView.playerView.pause()
            videoPlayerView.didTapPause()
        }
        
        /// Pre-Removing if error screen exists
        hideErrorSheet()
        /// Caching Audio/Video data after its rendered by VideoPlayer
        guard let urlAsset = self.videoPlayerView.playerView.playerItem?.asset as? AVURLAsset, urlAsset.isPlayable else { return }
        let cacheToStore = MBCacheableAV(cacheId: "\(urlAsset.url)", avAsset: urlAsset)
        localMediaCache = cacheToStore
        /// If file URL, then no need of caching
        self.delegate?.didFinishRenderingMedia(withIndexPath: self.browserIndex, cachedData: cacheToStore, isCachingRequired: !urlAsset.url.isFileURL)
    }
    
    func didFailToPlay() {
        handleError(content: .init(errorContent: .init(actionTitle: "Retry", title: "Video loading failed", image: MBConstants.Images.videoBrowserErrorImage, uiImage: placeHolder), properties: .init(appSection: className)))
    }
    
    func didTapPlay() {
        
    }
    
    func didTapPause() {
        
    }
    
}
