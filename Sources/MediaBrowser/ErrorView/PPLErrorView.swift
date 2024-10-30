//
//  ErrorRepresentableView.swift
//  Powerplay
//
//  Created by Gokul Nair on 01/10/22.
//

import Foundation
import UIKit

class MBErrorView: UIView {
    
    weak var delegate: ErrorViewRepresentable?
    
    /// Content stack padding
    var insets: UIEdgeInsets = .zero
    
    private var errorContent: ErrorViewContent?
    
    /// Error Image
    private(set) lazy var errorImage: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    /// Error Label
    lazy var errorLabel: PaddedLabel = {
        let lbl = PaddedLabel(padding: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
        lbl.textColor = .black
        lbl.font = .systemFont(ofSize: 20, weight: .semibold)
        lbl.adjustsFontSizeToFitWidth = true
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.numberOfLines = 3
        return lbl
    }()
    
    /// Error Screen Actionable button
    private(set) lazy var actionableButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = MBConstants.Color.browserTint
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = 4
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        return btn
    }()
    
    /// Error content stack
    private(set) lazy var contentStack: UIStackView = {
        let stck = UIStackView()
        stck.translatesAutoresizingMaskIntoConstraints = false
        stck.axis = .vertical
        stck.spacing = 10
        stck.alignment = .center
        return stck
    }()
    
    
    init(insets: UIEdgeInsets = .zero) {
        self.insets = insets
        super.init(frame:  UIScreen.main.bounds)
        
        addViews()
        layoutConstraints()
        addTargets()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Adds Error View as per content
    func addViews() {
        
        contentStack.addArrangedSubViews([errorImage, errorLabel, actionableButton, UIView()])
        
        self.addSubview(contentStack)
        
        self.backgroundColor = .white
    }
    
    /// Error Content layout
    func layoutConstraints() {
        
        // Center the contentStack in the superview and set height and width constraints
        NSLayoutConstraint.activate([
            contentStack.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            contentStack.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            contentStack.heightAnchor.constraint(lessThanOrEqualToConstant: 300),
            contentStack.widthAnchor.constraint(lessThanOrEqualToConstant: 300)
        ])

        // Set height constraint for errorLabel
        NSLayoutConstraint.activate([
            errorLabel.heightAnchor.constraint(lessThanOrEqualToConstant: 40)
        ])

        // Set height and width constraints for actionableButton
        NSLayoutConstraint.activate([
            actionableButton.heightAnchor.constraint(equalToConstant: 45),
            actionableButton.widthAnchor.constraint(equalTo: self.widthAnchor)
        ])
        
    }
    
    // Content based UI adoption
    private func adaptErrorScreen() {
        
        contentStack.isHidden = (errorContent?.error == nil)
        
    }
    
    private func addTargets() {
        actionableButton.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
    }
    
    /// Calls Navigable error, will check for default actions
    @objc private func didTapActionButton() {
        delegate?.didTapOnAction(errorType: .defaultError)
    }
    
    /// Shows Error on the presentable View
    /// - This method takes error as priority, if error is nil then checks for CustomUI View and even when CustomUI is nil then static content is consumed
    /// - If title is passed nil, then button gets hidden
    func showErrorScreen(content: ErrorViewContent) {
        
        /// Locally holding the error content
        errorContent = content
        /// Updating the view for error detail adoption since API failure Error, CustomUI or Static any content can arrive
        self.adaptErrorScreen()
        
        if let error = content.error {
            errorLabel.text = error.title
            errorImage.image = error.image ?? UIImage(named: "error_502")
            hideActionable(true)
            
        }
        else {
            if let attributedText = content.errorContent.attributedTitle{
                errorLabel.attributedText = attributedText
            }
            else{
                errorLabel.text = content.errorContent.title
            }
            errorImage.image = UIImage(named: content.errorContent.image)
            
            if let errorContentUIImage = content.errorContent.uiImage {
                errorImage.image = errorContentUIImage
            }
            
            actionableButton.setTitle(content.errorContent.actionTitle, for: .normal)
            hideActionable(content.errorContent.actionTitle == nil)
            
        }
    }
    
    /// Hides error from the presentable view
    func hideErrorScreen() {
        self.removeFromSuperview()
    }
    
    func hasError() -> Bool{
        return self.superview != nil
    }
    
    /// Hide actionable button
    private func hideActionable(_ state: Bool) {
        self.actionableButton.isHidden = state
    }
}
