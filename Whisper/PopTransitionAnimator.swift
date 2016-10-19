//
//  PopTransitionAnimator.swift
//  NavTransition
//
//  Created by Hayden on 2016/10/19.
//  Copyright © 2016年 AppCoda. All rights reserved.
//

import UIKit

class PopTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    
    let duration = 1.5
    var isPresenting = false
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        
        let container = transitionContext.containerView
        //        guard let container = transitionContext.containerView else {
        //            return
        //        }
        
        
        let minimise = CGAffineTransform(scaleX: 0, y: 0)
        let offScreenDown = CGAffineTransform(translationX: 0, y: container.frame.height)
        let shiftDown = CGAffineTransform(translationX: 0, y: 15)
        let scaleDown = shiftDown.scaledBy(x: 0.95, y: 0.95)
        
        toView.transform = minimise
        
        
        if isPresenting {
            container.addSubview(fromView)
            container.addSubview(toView)
        } else {
            container.addSubview(toView)
            container.addSubview(fromView)
        }

        
        // Perform the animation
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: [], animations: {
            
            if self.isPresenting {
                fromView.transform = scaleDown
                fromView.alpha = 1.0
                toView.transform = CGAffineTransform.identity
            } else {
                fromView.transform = offScreenDown
                fromView.alpha = 1.0
                toView.transform = CGAffineTransform.identity
            }
            
            
            }, completion: { finished in
                transitionContext.completeTransition(true)
        })
        
        
        
    }
    
    
    
    
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = true
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = false
        return self
    }

}
