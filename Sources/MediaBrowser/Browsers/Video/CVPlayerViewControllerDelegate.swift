//
//  CVPlayerViewController.swift
//  Powerplay
//
//  Created by Deepak Goyal on 07/08/23.
//

import UIKit

protocol CVPlayerViewControllerDelegate: AnyObject{
    
    // MARK: If URL is appropriate and video is Ready to playing / start playing
    func didReadyToPlay()
    
    // MARK: Something is wrong and video is failed to play
    func didFailToPlay()
    
    func didTapPlay()
    
    func didTapPause()
}

class CVPlayerViewController: UIViewController {
    
    
    private lazy var controlsOverLay: VideoControlsOverlayView = {
       let view = VideoControlsOverlayView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOverlayView))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    private(set) lazy var playerView: VideoPlayerLayerView = {
        let view = VideoPlayerLayerView(isAutoPlay: isAutoPlay)
        view.url = url
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapVideoView))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    private lazy var loader: MBLoadingView = {
        let view = MBLoadingView(withParentView: self.view, overlayInsets: UIEdgeInsets(top: CGFloat(MBConstants.Metrics.homeViewAppBarHeight) + 30, left: 0, bottom: 0, right: 0))
        view.setOverlayColor(.clear)
        view.setIndicatorStyle(.medium)
        view.setIndicatorColor(.gray)
        return view
    }()
    
    var url: URL?{
        didSet{
            playerView.url = url
        }
    }
    private var isAutoPlay = true
    private var pendingSeekRatio: Float?
    weak var delegate: CVPlayerViewControllerDelegate?
    private var seekFactor: Double = 10
    
    init(url: URL? = nil, isAutoPlay: Bool = true) {
        self.url = url
        self.isAutoPlay = isAutoPlay
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addViews()
        addLayoutConstraints()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        playerView.pause()
    }
    
    private func addViews(){
        self.view.addSubview(playerView)
        self.playerView.addSubview(controlsOverLay)
        controlsOverLay.isHidden = true
    }
    
    private func addLayoutConstraints(){
        
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
    
    /// Seconds you need to seek forward and backward
    /// - Parameter seconds: Eg if X then, on forward and backward tap video will be X seconds forward and X seconds backward
    func setSeekFactor(seconds: Double){
        self.seekFactor = seconds
    }
    
    @objc private func didTapVideoView(){
        controlsOverLay.isHidden = false
    }
    
    @objc private func didTapOverlayView(){
        controlsOverLay.isHidden = true
    }
}
extension CVPlayerViewController: VideoControlsOverlayViewDelegate{
    
    func didChangeSeek(withRatio ratio: Float) {
        
        pendingSeekRatio = ratio
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(changeSeek), object: nil)
        self.perform(#selector(changeSeek), with: nil, afterDelay: 1)
        self.loader.startLoading()
    }
    
    func didTapForward() {
        playerView.seek(seekFactor)
    }
    
    func didTapBackward() {
        playerView.seek(-seekFactor)
    }
    
    func didTapPlay() {
        playerView.play()
        delegate?.didTapPlay()
    }
    
    func didTapPause() {
        playerView.pause()
        delegate?.didTapPause()
    }
    
    @objc private func changeSeek(){
        playerView.seek(toRatio: pendingSeekRatio ?? 0)
        loader.stopLoading()
        pendingSeekRatio = nil
    }

}
extension CVPlayerViewController: VideoPlayerViewDelegate{
    
    func didChangePlayedDuration(withTime time: Double, ofDuration duration: Double) {
        
        guard pendingSeekRatio == nil else { return }
        controlsOverLay.set(playedDuration: time, totalDuration: duration)
    }
    
    func didReadyToPlay(ofDuration time: Double) {
        self.delegate?.didReadyToPlay()
        loader.stopLoading()
        controlsOverLay.set(playedDuration: 0, totalDuration: time)
    }
    
    func didFailedPlaying() {
        self.delegate?.didFailToPlay()
        loader.stopLoading()
        controlsOverLay.set(playedDuration: 0, totalDuration: 0)
    }
    
    func didLoadPlayer() {
        loader.startLoading()
    }
    
    func didPaused() {
        controlsOverLay.pause()
    }
    
    func didPlayed() {
        controlsOverLay.play()
    }

    func didEndPlaying() {
        controlsOverLay.pause()
        controlsOverLay.timeSlider.value = controlsOverLay.timeSlider.minimumValue
    }
}
