//
//  MediaBrowserView.swift
//  Powerplay
//
//  Created by Gokul Nair on 12/01/24.
//

import UIKit
import UXPagerView


@available(iOS 13.0, *)
class MediaBrowser: UIViewController {
    
    private lazy var pageViewControl: UXPagerView = {
        let pagerView = UXPagerView()
        pagerView.delegate = self
        pagerView.set(isTabViewHidden: true)
        pagerView.set(tabBackgroundColor: .black)
        pagerView.set(containerBackgroundColor: .black)
        return pagerView
    }()
    
    private lazy var dismissButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)), for: .normal)
        btn.tintColor = MBConstants.Color.browserTint
        return btn
    }()
    
    private lazy var browserTitleLabel: UILabel = {
        let lbl = UILabel()
      //  lbl.font = .primary(Ofsize: 18)
        lbl.adjustsFontSizeToFitWidth = true
        lbl.textAlignment = .center
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private lazy var browserOptionsButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "line.3.horizontal.decrease.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)), for: .normal)
        btn.tintColor = MBConstants.Color.browserTint
        return btn
    }()
    
    private lazy var upperNavBar: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var bottomNavBar: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var bottomNavBarStack: UIStackView = {
        let stck = UIStackView()
        stck.translatesAutoresizingMaskIntoConstraints = false
        stck.axis = .horizontal
        stck.spacing = 16
        stck.distribution = .fillEqually
        return stck
    }()
    
    private lazy var leftSwipeButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)), for: .normal)
        btn.tintColor = MBConstants.Color.browserTint
        return btn
    }()
    
    private lazy var rightSwipeButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)), for: .normal)
        btn.tintColor = MBConstants.Color.browserTint
        return btn
    }()
    
    
    private lazy var contentStack: UIStackView = {
        let stck = UIStackView()
        stck.translatesAutoresizingMaskIntoConstraints = false
        stck.axis = .vertical
        stck.spacing = 0
        return stck
    }()
    
    lazy var _errorView: MBErrorView = {
        let err = MBErrorView()
        err.delegate = self
        return err
    }()
    
    private lazy var loader: MBLoadingView = {
        let view = MBLoadingView(withParentView: self.view, overlayInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        view.setOverlayColor(.clear)
        view.loadingIndicator.color = .black
        view.loadingIndicator.layer.cornerRadius = 4
        return view
    }()
    
    // MARK: - Stored Properties
    
    /// Medias to be browsed by the browser
    private var media: [MediaBrowsable] = [] {
        didSet {
            computeBrowsableData()
        }
    }
    
    /// Set of media types to browse
    private var toBrowseMediaTypes: [MediaBrowserData] = []
    
    /// Set first launch browser index
    private var selectedIndex: Int = 0
    
    /// Flag to log current in session browser
    private var inSessionBrowser: MediaBrowserData?
    
    /// NavBar Visibility Toggle
    private var isToolBarVisible: Bool = true
    
    /// Available Browser Tools
    private var browserTools: [MBOperations] = []
    
    /// Default PlaceHolder Image for all browsers
    /*
     If you want to add specific image for each browser, then add the place holder image while converting, raw data to MediaBrowsable type.
     */
    private var placeHolderImage: UIImage?
    
    /// MediaBrowser Storage policy
    /*
     Supported Types: InMemory, UsingNSCache, DiskStorage
     (Check MBStoragePolicy for more details)
     */
    private var storagePolicy: MBStoragePolicy
    
    /// MediaBrowser View delegation
    weak var delegate: MediaBrowserDelegate?
    
    /// Parent class nav bar visibility flag
    private var isParentNavigationBarHidden = false
    
    init(storagePolicy: MBStoragePolicy = .InMemory, browserTools: [MBOperations] = []) {
        self.storagePolicy = storagePolicy
        self.browserTools = browserTools
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        isParentNavigationBarHidden = self.navigationController?.isNavigationBarHidden ?? false
        self.navigationController?.isNavigationBarHidden = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addViews()
        layoutConstraints()
        addTarget()
        
        setupView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        /// Checking for file eviction
        MediaBrowserFileManager.shared.checkForEviction()
        /// Navigation Bar visibility
        self.navigationController?.isNavigationBarHidden = isParentNavigationBarHidden
    }
    
    /// Basic UI setups
    private func setupView() {
        /// Default ViewController Implementation
        modalPresentationCapturesStatusBarAppearance = true
        modalPresentationStyle = .custom
        modalTransitionStyle = .crossDissolve
        /// View Layout Correction
        view.layoutIfNeeded()
        
        self.toggleBrowserOperationButtonVisibility(!browserTools.isEmpty)
    }
    
    private func addViews() {
        self.view.backgroundColor = .black
        
        self.view.addSubview(contentStack)
        contentStack.addArrangedSubViews([upperNavBar, pageViewControl, bottomNavBar])
        
        bottomNavBar.addSubview(bottomNavBarStack)
        bottomNavBarStack.addArrangedSubViews([leftSwipeButton, rightSwipeButton])
        
        upperNavBar.addSubview(dismissButton)
        upperNavBar.addSubview(browserTitleLabel)
        upperNavBar.addSubview(browserOptionsButton)
    }
    
    private func layoutConstraints() {
        
        NSLayoutConstraint.activate([
            browserTitleLabel.topAnchor.constraint(equalTo: upperNavBar.topAnchor, constant: 16),
            browserTitleLabel.bottomAnchor.constraint(equalTo: upperNavBar.bottomAnchor, constant: -16),
            browserTitleLabel.leadingAnchor.constraint(equalTo: upperNavBar.leadingAnchor, constant: 48),
            browserTitleLabel.trailingAnchor.constraint(equalTo: upperNavBar.trailingAnchor, constant: -48)
        ])
        
        NSLayoutConstraint.activate([
            bottomNavBarStack.topAnchor.constraint(equalTo: bottomNavBar.topAnchor, constant: 8),
            bottomNavBarStack.bottomAnchor.constraint(equalTo: bottomNavBar.bottomAnchor, constant: -8),
            bottomNavBarStack.leadingAnchor.constraint(equalTo: bottomNavBar.leadingAnchor, constant: 16),
            bottomNavBarStack.trailingAnchor.constraint(equalTo: bottomNavBar.trailingAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            dismissButton.widthAnchor.constraint(equalToConstant: 48),
            dismissButton.heightAnchor.constraint(equalToConstant: 48),
            dismissButton.leadingAnchor.constraint(equalTo: upperNavBar.leadingAnchor, constant: 8),
            dismissButton.centerYAnchor.constraint(equalTo: upperNavBar.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            browserOptionsButton.widthAnchor.constraint(equalToConstant: 48),
            browserOptionsButton.heightAnchor.constraint(equalToConstant: 48),
            browserOptionsButton.trailingAnchor.constraint(equalTo: upperNavBar.trailingAnchor, constant: -8),
            browserOptionsButton.centerYAnchor.constraint(equalTo: upperNavBar.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            upperNavBar.heightAnchor.constraint(equalToConstant: 52)
        ])
        
        NSLayoutConstraint.activate([
            bottomNavBar.heightAnchor.constraint(equalToConstant: 64)
        ])
        
        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            contentStack.topAnchor.constraint(equalTo: self.view.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -16)
        ])
        
    }
    
    private func addTarget() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnView))
        self.view.addGestureRecognizer(tapGesture)
        
        dismissButton.addTarget(self, action: #selector(didTapOnDismissButton), for: .touchUpInside)
        rightSwipeButton.addTarget(self, action: #selector(didTapOnRightSwipeButton), for: .touchUpInside)
        leftSwipeButton.addTarget(self, action: #selector(didTapOnLeftSwipeButton), for: .touchUpInside)
        
        if #available(iOS 14.0, *) {
            browserOptionsButton.showsMenuAsPrimaryAction = true
            didTapOnBrowserOptionButton(sender: browserOptionsButton)
        }
        
    }
    
    /// View tap Action
    @objc private func didTapOnView() {
        toggleNavBarWithAnimation()
    }
    
    /// Left Swipe Button action
    @objc private func didTapOnLeftSwipeButton() {
        
        if selectedIndex > 0 {
            
            HapticManager.shared.giveLightImpactFeedback()
            
            self.storeInSessionBrowser(index: (selectedIndex - 1), shouldReloadPager: true)
        }
    }
    
    /// Right Swipe Button action
    @objc private func didTapOnRightSwipeButton() {
        
        if selectedIndex < (toBrowseMediaTypes.count - 1) {
            
            HapticManager.shared.giveLightImpactFeedback()
            
            self.storeInSessionBrowser(index: (selectedIndex + 1), shouldReloadPager: true)
        }
        
    }
    
    @available(iOS 14.0, *)
    @objc func didTapOnBrowserOptionButton(sender: UIButton) {
        
        let shareAction = UIAction(title: MBOperations.Share.rawValue) { action in
            
            if let cachedData = self.inSessionBrowser?.cachedData {
                
                DispatchQueue.global(qos: .background).async { [weak self] in
                    guard let self else { return }
                    
                    cachedData.generateShareableData { [weak self] (items, status, error) in
                        
                        self?.handleLoader(withStatus: status)
                        
                        if let items {
                            self?.showShareSheet(withItems: [items])
                        }
                        
                        if let error {
                            self?.showAlert(title: "Error", message: error.localizedDescription)
                        }
                    }
                }
            } else {
                
                self.showAlert(title: "Warning", message: "The media is currently undergoing rendering; please wait for the data to be processed before sharing.")
            }
            
        }
        
        var menuChildren: [UIAction] = []
        
        browserTools.forEach { tool in
            
            switch tool {
            case .Share:
                menuChildren.append(shareAction)
                break
            }
        }
        
        let menu = UIMenu(title: "", children: menuChildren)
        self.browserOptionsButton.menu = menu
    }
    
    @objc private func didTapOnDismissButton() {
        self.delegate?.willDismissMediaBrowserAtPageIndex(withIndex: selectedIndex, browser: self)
        self.dismiss(animated: true)
    }
    
    private func handleLoader(withStatus status: MBUploadStatus) {
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            switch status {
            case .Inprogress:
                self.loader.startLoading(withTitle: "Loading....")
                break
            case .Failed:
                self.loader.stopLoading()
                break
            case .Completed:
                self.loader.stopLoading()
                break
            }
        }
    }
}

// MARK: - Utility Methods
@available(iOS 13.0, *)
extension MediaBrowser {
    
    /// Medias to be rendered by the Browser
    /// - Parameters:
    ///   - media: Media(MediaBrowsable) to be rendered
    ///   - index: Index from which browsing needs to begin
    func render(media: [MediaBrowsable], withSelectedIndex index: Int = 0) {
        self.media = media
        let preSelectedIndex = (index < media.count) ? index : 0
        self.pageViewControl.defaultSelectedTab = preSelectedIndex
        self.storeInSessionBrowser(index: preSelectedIndex, shouldReloadPager: false)
    }
    
    /// Setting default image for all browsers
    /// - Parameter placeHolderImage: Place holder UIImage for the browser
    func set(placeHolderImage: UIImage) {
        self.placeHolderImage = placeHolderImage
    }
}

// MARK: - Operations
@available(iOS 13.0, *)
extension MediaBrowser {
    
    /// Toggle Nav bar animation
    private func toggleNavBarWithAnimation() {
        
        bottomNavBar.alpha = isToolBarVisible ? 1 : 0
        upperNavBar.alpha = isToolBarVisible ? 1 : 0
        isToolBarVisible.toggle() /// On Tap toggle the bool
        
        if bottomNavBar.alpha == 1.0 {
            UIView.animate(withDuration: 0.5, animations: { [weak self] in
                self?.bottomNavBar.alpha = 0.0
                self?.upperNavBar.alpha = 0.0
                
            }) { (_) in }
        } else {
            bottomNavBar.isHidden = false
            UIView.animate(withDuration: 0.5) { [weak self] in
                self?.bottomNavBar.alpha = 1.0
                self?.upperNavBar.alpha = 1.0
            }
        }
        
        self.delegate?.mediaBrowserControlVisibilityToggled(browser: self, hidden: isToolBarVisible)
    }
    
    /// Show Share Sheet
    private func showShareSheet(withItems items: [Any]) {
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
            
            // On iPad, you need to specify a source view or bar button item for the popover to anchor to
            activityViewController.popoverPresentationController?.sourceView = self.view
            
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    /// UpdateBrowserTitle
    private func updateBrowserTitle(index: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.browserTitleLabel.text = "\(index + 1)/\(toBrowseMediaTypes.count)"
        }
    }
    
    /// UpdateBrowserTitle
    private func updateSwipeButtonInteraction(index: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.leftSwipeButton.isEnabled = (index != 0)
            self.leftSwipeButton.isUserInteractionEnabled = (index != 0)
            self.rightSwipeButton.isEnabled = (index != (media.count - 1))
            self.rightSwipeButton.isUserInteractionEnabled = (index != (media.count - 1))
        }
    }
    
    /// Toggle Browser Operations Visibility
    private func toggleBrowserOperationButtonVisibility(_ state: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.browserOptionsButton.isHidden = !state
        }
    }
    
    /// Set Browser selection index
    private func storeInSessionBrowser(index: Int, shouldReloadPager: Bool = false) {
        
        selectedIndex = index
        
        if shouldReloadPager {
            self.pageViewControl.set(selectedTabIndex: selectedIndex)
        }
        
        self.updateBrowserTitle(index: selectedIndex)
        self.updateSwipeButtonInteraction(index: selectedIndex)
        
        /// Logging Current InSession Browser
        guard let currentBrowser = toBrowseMediaTypes[safeIndex: selectedIndex] else { return }
        self.inSessionBrowser = currentBrowser
        
        self.delegate?.mediaBrowserDidSwipe(withIndex: selectedIndex, browser: self)
    }
    
    /// Toggle Browser title Visibility
    private func toggleBrowserTitleVisibility(_ state: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.browserTitleLabel.isHidden = !state
        }
    }
    
    /// Alert View
    private func showAlert(title: String, message: String) {
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel))
            
            self.present(alert, animated: true)
        }
    }
    
}

// MARK: - Storage base operations
@available(iOS 13.0, *)
extension MediaBrowser {
    
    /// Computing raw media data to MediaBrowsable format
    private func computeBrowsableData() {
        
        if !media.isEmpty {
            
            self.toBrowseMediaTypes.append(contentsOf: getMediaBrowserData())
            
            hideErrorSheet()
            
            /// After Initial boot, first browser needs to be explicitly set
            guard let currentBrowser = toBrowseMediaTypes[safeIndex: selectedIndex] else { return }
            self.inSessionBrowser = currentBrowser
            
        } else {
            
            handleError(content: .init(errorContent: .init(title: "No Images found", image: "error_504"), properties: .init(appSection: className)))
        }
        
        
        self.toggleBrowserTitleVisibility(!media.isEmpty)
        self.toggleBrowserOperationButtonVisibility(!browserTools.isEmpty && !media.isEmpty)
        
    }
    
    private func getMediaBrowserData() -> [MediaBrowserData] {
        
        return media.compactMap({ MediaBrowserData(mediaType: $0.transformToBrowsableMedia(), placeHolder: $0.placeHolderImage) })
        
    }
    
    /// Checks for Storage policy and stores the media as per policy
    private func checkForStoragePolicyAndStoreMedia(cachedData: MBCacheable) {
        
        switch storagePolicy {
        case .InMemory:
            /* 
             Already did, this is mandatory for every type of storage since for an active session of MediaManager,
             InMemory cache is used rather than fetching it from NSCache/Disk
             */
            break
        case .UsingNSCache:
            MediaBrowserCacheManager.shared.store(media: cachedData)
            break
        case .DiskStorage:
            MediaBrowserFileManager.shared.store(witheData: cachedData)
            break
        }
        
    }
}

// MARK: - UXPagerViewDelegate
@available(iOS 13.0, *)
extension MediaBrowser: UXPagerViewDelegate {
    
    func pagerView(_ view: UXPagerView, tabTitleAtIndex index: Int) -> String {
        return ""
    }
    
    func pagerView(_ view: UXPagerView, pageAtIndex index: Int) -> UIViewController? {
        
        guard let _toBrowseMediaType = toBrowseMediaTypes[safeIndex: index], let type = _toBrowseMediaType.mediaType else { return UIViewController() }
        
        /// If no image is set explicitly use the default image set via MediaBrowser, even when this is empty the MBConstant Images are used
        let _placeHolderImage = _toBrowseMediaType.placeHolder ?? placeHolderImage
        
        switch type {
        case .Image(let image):
            let viewController = MBPhotoBrowserViewController(image: image, placeHolder: _placeHolderImage, localMediaCache: _toBrowseMediaType.cachedData, storagePolicy: storagePolicy)
            viewController.browserIndex = index
            viewController.delegate = self
            return viewController
            
        case .Photo(let url):
            let viewController = MBPhotoBrowserViewController(url: url, placeHolder: _placeHolderImage, localMediaCache: _toBrowseMediaType.cachedData, storagePolicy: storagePolicy)
            viewController.browserIndex = index
            viewController.delegate = self
            return viewController
            
        case .Video(let url):
            let viewController = MBVideoBrowserViewController(url: url, placeHolder: _placeHolderImage, localMediaCache: _toBrowseMediaType.cachedData, storagePolicy: storagePolicy)
            viewController.browserIndex = index
            viewController.delegate = self
            return viewController
            
        case .Documents(let url):
            let viewController = MBDocumentBrowserViewController(url: url, placeHolder: _placeHolderImage, localMediaCache: _toBrowseMediaType.cachedData, storagePolicy: storagePolicy)
            viewController.browserIndex = index
            viewController.delegate = self
            return viewController
            
        case .Web(let url):
            let viewController = MBWebBrowserViewController(url: url, placeHolder: _placeHolderImage, localMediaCache: _toBrowseMediaType.cachedData, storagePolicy: storagePolicy)
            viewController.browserIndex = index
            viewController.delegate = self
            return viewController
        }
    }
    
    func numberOfPages(_ view: UXPagerView) -> Int {
        return toBrowseMediaTypes.count
    }
    
    func pagerView(_ view: UXPagerView, didSwipeTabTo index: Int) {
        self.storeInSessionBrowser(index: index, shouldReloadPager: false)
    }
}

// MARK: - MediaBrowserBaseViewDelegate
@available(iOS 13.0, *)
extension MediaBrowser: MediaBrowserBaseViewDelegate {
    
    func didFinishRenderingMedia(withIndexPath index: Int, cachedData: MBCacheable?, isCachingRequired: Bool) {
        
        guard let renderingFinishedBrowserId = toBrowseMediaTypes[safeIndex: index]?.id,
              let index = toBrowseMediaTypes.firstIndex(where: { $0.id == renderingFinishedBrowserId }) else { return }
        
        /*When a browser data is cached and the same browser is currently in session, then replace the empty cache with cached data*/
        if selectedIndex == index {
            inSessionBrowser?.set(cachedData: cachedData)
        }
        
        if let cachedData, isCachingRequired {
            /// In memory caching,
            /// Necessary since, we use this cached data locally while initialising new browsers in an active session
            toBrowseMediaTypes[index].set(cachedData: cachedData)
            /// Checking for other policy based caching
            checkForStoragePolicyAndStoreMedia(cachedData: cachedData)
            
        }
    }
    
    func didFailRenderingMedia(withIndexPath index: Int, error: MediaManagerError) {
        
    }
}

// MARK: - ErrorViewRepresentable
@available(iOS 13.0, *)
extension MediaBrowser: ErrorViewRepresentable {
    
    var errorView: MBErrorView {
        return _errorView
    }
    
    var parentView: UIView {
        return self.pageViewControl
    }
}
