//
//  CVPlayerViewController.swift
//  MediaBrowser
//
//  Created by Gokul Nair(Work) on 04/11/24.
//

import UIKit


/// A view controller that manages video playback with a custom overlay for video controls, loading indicator, and player actions like play, pause, seek, forward, and backward. This controller uses `VideoPlayerLayerView` for displaying the video and `VideoControlsOverlayView` for control interactions.
class CVPlayerViewController: UIViewController {
    
    // Overlay view for video controls with delegate for handling interactions
    private lazy var controlsOverLay: VideoControlsOverlayView = {
       let view = VideoControlsOverlayView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOverlayView))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    // View that handles video rendering and playback
    private(set) lazy var playerView: VideoPlayerLayerView = {
        let view = VideoPlayerLayerView(isAutoPlay: isAutoPlay)
        view.url = url
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapVideoView))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    // Loading indicator overlay to show buffering or loading state
    private lazy var loader: MBLoadingView = {
        let view = MBLoadingView(withParentView: self.view, overlayInsets: UIEdgeInsets(top: CGFloat(MBConstants.Metrics.homeViewAppBarHeight) + 30, left: 0, bottom: 0, right: 0))
        view.setOverlayColor(.clear)
        view.setIndicatorStyle(.medium)
        view.setIndicatorColor(.gray)
        return view
    }()
    
    // URL for the video to be played
    var url: URL? {
        didSet {
            playerView.url = url
        }
    }
    
    // Determines if the video should play automatically on load
    private var isAutoPlay = true
    
    // Stores a pending seek ratio for delayed seek operations
    private var pendingSeekRatio: Float?
    
    // Delegate to handle playback events
    weak var delegate: CVPlayerViewControllerDelegate?
    
    // Factor in seconds to skip forward/backward in the video
    private var seekFactor: Double = 10
    
    // Initializer with optional URL and autoplay configuration
    init(url: URL? = nil, isAutoPlay: Bool = true) {
        self.url = url
        self.isAutoPlay = isAutoPlay
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Sets up the views and constraints on load
    override func viewDidLoad() {
        super.viewDidLoad()
        addViews()
        addLayoutConstraints()
    }
    
    // Pauses video playback when the view disappears
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        playerView.pause()
    }
    
    // Adds player view and controls overlay to the view hierarchy
    private func addViews() {
        self.view.addSubview(playerView)
        self.playerView.addSubview(controlsOverLay)
        controlsOverLay.isHidden = true
    }
    
    // Adds layout constraints for player view and controls overlay
    private func addLayoutConstraints() {
        
        NSLayoutConstraint.activate([
            controlsOverLay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controlsOverLay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controlsOverLay.topAnchor.constraint(equalTo: view.topAnchor),
            controlsOverLay.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerView.topAnchor.constraint(equalTo: view.topAnchor),
            playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    /// Sets the seconds to skip forward or backward in the video
    /// - Parameter seconds: The skip interval in seconds
    func setSeekFactor(seconds: Double) {
        self.seekFactor = seconds
    }
    
    // Handles tap on video view to show controls overlay
    @objc private func didTapVideoView() {
        controlsOverLay.isHidden = false
    }
    
    // Handles tap on overlay view to hide controls overlay
    @objc private func didTapOverlayView() {
        controlsOverLay.isHidden = true
    }
}

// MARK: - VideoControlsOverlayViewDelegate
extension CVPlayerViewController: VideoControlsOverlayViewDelegate {
    
    // Updates seek position in the video with a delay
    func didChangeSeek(withRatio ratio: Float) {
        pendingSeekRatio = ratio
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(changeSeek), object: nil)
        self.perform(#selector(changeSeek), with: nil, afterDelay: 1)
        self.loader.startLoading()
    }
    
    // Seeks forward by the seek factor
    func didTapForward() {
        playerView.seek(seekFactor)
    }
    
    // Seeks backward by the seek factor
    func didTapBackward() {
        playerView.seek(-seekFactor)
    }
    
    // Starts video playback and notifies delegate
    func didTapPlay() {
        playerView.play()
        delegate?.didTapPlay()
    }
    
    // Pauses video playback and notifies delegate
    func didTapPause() {
        playerView.pause()
        delegate?.didTapPause()
    }
    
    // Applies the pending seek ratio and stops loader animation
    @objc private func changeSeek() {
        playerView.seek(toRatio: pendingSeekRatio ?? 0)
        loader.stopLoading()
        pendingSeekRatio = nil
    }
}

// MARK: - VideoPlayerViewDelegate
extension CVPlayerViewController: VideoPlayerViewDelegate {
    
    // Updates the played duration on the controls overlay
    func didChangePlayedDuration(withTime time: Double, ofDuration duration: Double) {
        guard pendingSeekRatio == nil else { return }
        controlsOverLay.set(playedDuration: time, totalDuration: duration)
    }
    
    // Called when the video is ready to play, stops loading animation
    func didReadyToPlay(ofDuration time: Double) {
        delegate?.didReadyToPlay()
        loader.stopLoading()
        controlsOverLay.set(playedDuration: 0, totalDuration: time)
    }
    
    // Called if the video fails to play, stops loading and resets overlay
    func didFailedPlaying() {
        delegate?.didFailToPlay()
        loader.stopLoading()
        controlsOverLay.set(playedDuration: 0, totalDuration: 0)
    }
    
    // Starts loader animation when video is loading
    func didLoadPlayer() {
        loader.startLoading()
    }
    
    // Pauses controls overlay when video is paused
    func didPaused() {
        controlsOverLay.pause()
    }
    
    // Resumes controls overlay when video is playing
    func didPlayed() {
        controlsOverLay.play()
    }

    // Resets controls overlay when video playback ends
    func didEndPlaying() {
        controlsOverLay.pause()
        controlsOverLay.timeSlider.value = controlsOverLay.timeSlider.minimumValue
    }
}
