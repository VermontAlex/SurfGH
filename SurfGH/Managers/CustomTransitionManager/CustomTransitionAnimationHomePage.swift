//
//  CustomTransitionAnimationHomePage.swift
//  SurfGH
//
//  Created by Oleksandr Oliinyk
//

import UIKit

final class CustomTransitionAnimaionHomePage: NSObject, UIViewControllerAnimatedTransitioning {
    
    let transitionDuration: Double
    
    init(transitionDuration: Double) {
        self.transitionDuration = transitionDuration
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to),
              let fromView = transitionContext.viewController(forKey: .from)?.view
        else { return  transitionContext.completeTransition(false) }
        
        let containerView = transitionContext.containerView
        
        let beginState = CGAffineTransform(translationX: 0, y: -containerView.frame.height)
        let endState = CGAffineTransform(translationX: 0, y: containerView.frame.height)
        
        toView.transform = beginState
        
        containerView.addSubview(toView)
        containerView.addSubview(fromView)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext)) {
            
            toView.transform = .identity
            fromView.transform = endState
            
            
        } completion: { (isFinished) in
            transitionContext.completeTransition(isFinished)
        }
    }
}
