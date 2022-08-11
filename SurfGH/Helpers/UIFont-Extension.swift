//
//  UIFont-Extension.swift
//  GitHub Viewer
//
//  Created by Oleksandr Oliinyk
//

import UIKit
extension UIFont {
    
    public enum SFProText: String {
        case regular = "SFProText-Regular"
        case medium = "SFProText-Medium"
        case semibold = "SFProText-Semibold"
        case bold = "SFProText-Bold"
    }
    
    public static func sf(style: SFProText, size: CGFloat) -> UIFont {
        return UIFont(name: style.rawValue, size: size) ?? UIFont.systemFont(ofSize: size)
    }
}
