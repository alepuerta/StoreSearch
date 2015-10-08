//
//  FadeOutAnimationController.swift
//  StoreSearch
//
//  Created by usuario on 8/10/15.
//  Copyright © 2015 Insoftcan. All rights reserved.
//

import UIKit

class FadeOutAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.4
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey) {
            let duration = transitionDuration(transitionContext)
            
            UIView.animateWithDuration(duration,
                animations: {
                    fromView.alpha = 0
                },
                completion: { finished in
                    transitionContext.completeTransition(true)
            })
        }
    }
}
