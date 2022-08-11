//
//  UIView-Extensions.swift
//  GitHub Viewer
//
//  Created by Oleksandr Oliinyk
//

import UIKit

public extension UIView {
    
    class var className: String {
        let stringClassName = NSStringFromClass(self)
        guard let range = stringClassName.range(of: ".") else { return "" }
        
        return String(stringClassName[range.upperBound...])
    }
    
    class func nib() -> UINib {
        return UINib(nibName: className, bundle: Bundle(for: self))
    }
    
    func addEdgeConstrainsToSuperview(insets: UIEdgeInsets = .zero) {
        guard let superview = superview else { return }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        let constraints: [NSLayoutConstraint] = [
            topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -insets.bottom),
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -insets.right)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func dropShadow(cornerRadius: CGFloat,
                    shadowRadius: CGFloat? = nil,
                    backgroundColor: UIColor? = nil,
                    color: UIColor = UIColor(white: 0, alpha: 0.175),
                    opacity: Float,
                    size: CGSize) {
        
        if let bgColor = backgroundColor {
            self.backgroundColor = .clear
            layer.backgroundColor = bgColor.cgColor
        }
        
        layer.masksToBounds = false
        layer.cornerRadius = cornerRadius
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius = shadowRadius ?? cornerRadius
        layer.shadowOffset = size
    }
}
