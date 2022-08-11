//
//  TouchedView.swift
//  SurfGH
//
//  Created by Oleksandr Oliinyk
//

import Combine
import UIKit

class TouchedView: UIView {
    
    var resignViewPublisher = PassthroughSubject<Bool, Never>()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.removeFromSuperview()
        resignViewPublisher.send(true)
    }
}
