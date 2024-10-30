//
//  MBLoadingView.swift
//  MediaBrowser
//
//  Created by Gokul Nair(Work) on 30/10/24.
//

import UIKit


class MBLoadingView {
    
    lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.color = MBConstants.Color.loaderTint
        indicator.hidesWhenStopped = true
        indicator.style = .large
        return indicator
    }()
    
    private lazy var titleLbl: PaddedLabel = {
        let lbl = PaddedLabel()
       // lbl.font = .primary(Ofsize: 14)
        lbl.textColor = .black
        lbl.backgroundColor = .white
        lbl.layer.cornerRadius = 4
        lbl.sizeToFit()
        return lbl
    }()
   
    lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.28)
        return view
    }()
    
    private var parentView: UIView?
    private var overlayEdges: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    func setOverlayColor(_ color: UIColor){
        overlayView.backgroundColor = color
    }
    
    func setIndicatorStyle(_ style: UIActivityIndicatorView.Style){
        loadingIndicator.style = style
    }
    
    func setIndicatorColor(_ color: UIColor){
        loadingIndicator.color = color
    }
    
    init(withParentView view: UIView?, overlayInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)){
        self.parentView = view
        self.overlayEdges = overlayInsets
        self.addViews()
        self.layoutConstraints()
        titleLbl.isHidden = true
    }
    
    
    private func addViews(){
        
        self.overlayView.addSubview(titleLbl)
        self.overlayView.addSubview(loadingIndicator)
        self.parentView?.addSubview(overlayView)
    }
    
    private func layoutConstraints(){
        
        guard let parentView else { return }
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: parentView.centerYAnchor)
        ])

        // Position `titleLbl` below `loadingIndicator` with an 8-point offset and center horizontally
        NSLayoutConstraint.activate([
            titleLbl.topAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: 8),
            titleLbl.centerXAnchor.constraint(equalTo: parentView.centerXAnchor)
        ])

        // Set `overlayView` to have edges inset by `overlayEdges`
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: parentView.topAnchor, constant: overlayEdges.top),
            overlayView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: overlayEdges.left),
            overlayView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -overlayEdges.right),
            overlayView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: -overlayEdges.bottom)
        ])
    }
    
    //Shows the Activity Indicator and starts animation
    func startLoading(){
        
        DispatchQueue.main.async { [weak self] in
            self?.loadingIndicator.startAnimating()
            self?.loadingIndicator.isHidden = false
            self?.overlayView.isHidden = false
            self?.titleLbl.isHidden = true
            
            if let overlayView = self?.overlayView{
                self?.parentView?.bringSubviewToFront(overlayView)
            }
        }
    }
    
    //Hides the Activity Indicator and stops animation
    func stopLoading(){
        
        DispatchQueue.main.async { [weak self] in
            self?.overlayView.isHidden = true
            self?.loadingIndicator.stopAnimating()
            self?.loadingIndicator.isHidden = true
        }
    }
    
    //Shows the Activity Indicator and starts animation
    func startLoading(withTitle title: String?){
        
        DispatchQueue.main.async { [weak self] in
            self?.titleLbl.isHidden = title?.isBlank() ?? true
            self?.titleLbl.text = title
            self?.loadingIndicator.startAnimating()
            self?.loadingIndicator.isHidden = false
            self?.overlayView.isHidden = false
            
            if let overlayView = self?.overlayView{
                self?.parentView?.bringSubviewToFront(overlayView)
            }
        }
    }
}

