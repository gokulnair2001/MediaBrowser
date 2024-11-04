//
//  MBBrowserBaseViewController.swift
//  Powerplay
//
//  Created by Gokul Nair on 30/01/24.
//

import UIKit

/*
 Media Browser consists variety of browsers which are used to render various kinds of media. Every browser included in Media Browser must be a child class of MBBrowserBaseViewController.
 
 MBBrowserBaseViewController consists of basic setup for every browser, this helps to make the browsing process same for all Browsers
 
 Future Prospect: In future when we need to introduce any new browser(Eg: Advertisement service), then create child class of this base view
 */
class MBBrowserBaseViewController: UIViewController {
    
    /// View Loader
    lazy var loader: MBLoadingView = {
        let view = MBLoadingView(withParentView: self.view, overlayInsets: UIEdgeInsets(top: CGFloat(MBConstants.Metrics.homeViewAppBarHeight) + 30, left: 0, bottom: 0, right: 0))
        view.setOverlayColor(.clear)
        view.loadingIndicator.color = MBConstants.Color.browserTint
        return view
    }()
    
    /// Error View
    lazy var _errorView: MBErrorView = {
        let err = MBErrorView()
        err.delegate = self
        err.backgroundColor = .black
        err.errorLabel.textColor = .white
        err.actionableButton.backgroundColor = .clear
        err.actionableButton.setTitleColor(MBConstants.Color.browserTint, for: .normal)
        return err
    }()
    
    /// Media Browser view browser Index
    var browserIndex: Int = 0
    
    /// RAW media URL
    /// This value is substituted with local file path if its pre-cached in disk
    var mediaUrl: URL?
    
    /// Local Media Cache for each browser
    var localMediaCache: MBCacheable?
    
    /// PlaceHolder image for every browser
    /// This Image is used in error/failure case if explicitly set, and if not set then the MBConstant Images are used
    var placeHolder: UIImage?
    
    /// Storage Policy
    /// Informs Browser to use which storage policy
    private var storagePolicy: MBStoragePolicy
    
    /// Browser Delegate
    weak var delegate: MediaBrowserBaseViewDelegate?
    
    /// Default Initialiser for every browser
    init(url: URL?, placeHolder: UIImage?, localMediaCache: MBCacheable?, storagePolicy: MBStoragePolicy) {
        
        self.storagePolicy = storagePolicy
        
        super.init(nibName: nil, bundle: nil)
        
        self.mediaUrl = url
        self.placeHolder = placeHolder
        /// Once pre-cache file is found from internal storage, its locally maintained in-memory, to be used by browser when media is rendered again in same session
        self.localMediaCache = localMediaCache
    
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /// Check for local cache on every appear
        /// Note: Media Rendering is initiated by respective child browser
        if let mediaUrl, localMediaCache == nil {
            
            switch storagePolicy {
            case .InMemory:
                break
            case .UsingNSCache:
                self.localMediaCache = MediaBrowserCacheManager.shared.getCache(forId: "\(mediaUrl)")
                break
            case .DiskStorage:
                if let diskFileURL = MediaBrowserFileManager.shared.get(url: "\(mediaUrl)") {
                    self.mediaUrl = diskFileURL
                }
                break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addViews()
        layoutConstraints()
        addTarget()
        registerViewModel()
    }
    
    func addViews() {
        /// Used in Child Browsers
    }
    
    func layoutConstraints() {
        /// Used in Child Browsers
    }
    
    func addTarget() {
        /// Used in Child Browsers
    }
    
    func registerViewModel() {
        /// Used in Child Browsers
    }
    
    func getErrorRepresentableView() -> UIView {
        return self.view
    }
    
    func didTapOnAction(errorType: ErrorType) {
        /// Used in Child Browsers
    }
    
}

// MARK: - ErrorViewRepresentable
extension MBBrowserBaseViewController: ErrorViewRepresentable {
    
    var errorView: MBErrorView {
        return _errorView
    }
    
    var parentView: UIView {
        return getErrorRepresentableView()
    }
    
}
