//
//  TouchedView.swift
//  SurfGH
//
//  Created by Oleksandr Oliinyk
//

import UIKit

class TouchedView: UIView {
    
    var resignView: (() -> Void)?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.removeFromSuperview()
        if let completion = resignView {
            completion()
        }
    }
}
