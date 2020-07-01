//
//  CustomButton.swift
//  MASegmentedControl
//
//  Created by Phu Ho on 6/29/20.
//  Copyright © 2020 Alok Choudhary. All rights reserved.
//

import UIKit

enum AnimateState {
    case collapse
    case expanded
    
    var change: AnimateState {
        switch self {
        case .collapse: return .expanded
        case .expanded: return .collapse
        }
    }
}

@IBDesignable
public class CustomButton: UIButton {
    
    var animateState: AnimateState = .expanded
    private var isAnimating = false
    
    @IBInspectable
    public var subTitle: String = "" {
        didSet {
            subTitleLabel.text = subTitle
            updateViews()
        }
    }
    
    public lazy var anime: Int = {
        return 7
    }()
    
    public lazy var animator: UIViewPropertyAnimator = {
        return UIViewPropertyAnimator(duration: 0.33, curve: .easeIn)
    }()
    
    public var subTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.sizeToFit()
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        self.addSubview(subTitleLabel)
        titleLabel?.textAlignment = .right
    }
    
    private func updateViews() {
        guard let titleLabel = titleLabel else { return }
        
        let subTitleWidth = subTitleLabel.text?.width(withConstrainedHeight: 35, font: subTitleLabel.font)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: -subTitleWidth!/2),
            subTitleLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 0),
            subTitleLabel.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0)
        ])
    }
    
    public func toggle() {
        switch animateState {
        case .collapse:
            expand()
        case .expanded:
            collapse()
        }
    }
    
    public func collapse() {
        if isAnimating || animateState == .collapse { return }

        isAnimating = true
        guard let titleLabel = titleLabel else { return }
        
        animator.addAnimations {
            
            let subTitleWidth = self.subTitleLabel.frame.width
            titleLabel.frame = titleLabel.frame.offsetBy(dx: subTitleWidth/2, dy: 0)
            self.subTitleLabel.frame.origin.x += subTitleWidth/2
        }
        
        animator.addAnimations({
            self.subTitleLabel.alpha = 0
        }, delayFactor: 0.33)
        
        animator.addCompletion { (position) in
            switch position {
            case .end:
                self.animateState = self.animateState.change
            default:
                ()
            }
            
            self.isAnimating = false
        }
        animator.startAnimation()
    }
    
    public func expand() {
        
        if isAnimating || animateState == .expanded { return }
        
        isAnimating = true
        animator.addAnimations({
            self.subTitleLabel.alpha = 1
        }, delayFactor: 0)
        
        
        animator.addAnimations({
            self.titleLabel?.center.x -= self.subTitleLabel.frame.width / 2
            self.subTitleLabel.center.x -= self.subTitleLabel.frame.width / 2
        }, delayFactor: 0)
        
        animator.addCompletion { (position) in
            switch position {
            case .end:
                self.animateState = self.animateState.change
            default:
                ()
            }
            
            self.isAnimating = false
        }
        animator.startAnimation()
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.width)
    }
}
