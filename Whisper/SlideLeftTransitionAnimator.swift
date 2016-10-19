//
//  SlideRightTransitionAnimator.swift
//  NavTransition
//
//  Created by Hayden on 2016/10/19.
//  Copyright © 2016年 AppCoda. All rights reserved.
//

import UIKit

class SlideLeftTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    
    let duration = 0.5
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
        
        
        let offScreenUp = CGAffineTransform(translationX: container.frame.width, y: 0)
        let offScreenDown = CGAffineTransform(translationX: -container.frame.width, y: 0)
        
        if isPresenting {
            toView.transform = offScreenUp
        }
        
        container.addSubview(fromView)
        container.addSubview(toView)
        
        // Perform the animation
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: [], animations: {
            
            if self.isPresenting {
                fromView.transform = offScreenDown
                fromView.alpha = 1.0
                toView.transform = CGAffineTransform.identity
            } else {
                fromView.transform = offScreenUp
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
