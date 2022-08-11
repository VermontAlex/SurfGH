//
//  RootDefaultView.swift
//  SurfGH
//
//  Created by Oleksandr Oliinyk
//

import UIKit

final class RootDefaultView: UIView {
    
    private lazy var successLoginWelcome: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.sf(style: .regular, size: 100)
        label.textColor = UIColor.lightGray
        label.text = "Welcome!"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        self.backgroundColor = UIColor(named: "creamBlueColor")
        self.addSubview(self.successLoginWelcome)
        successLoginWelcome.addEdgeConstrainsToSuperview()
        successLoginWelcome.alpha = 0
        UIView.animate(withDuration: 0.5) {
            self.successLoginWelcome.alpha = 1
        }
    }
}
