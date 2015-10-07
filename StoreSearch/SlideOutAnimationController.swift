//
//  SlideOutAnimationController.swift
//  StoreSearch
//
//  Created by usuario on 7/10/15.
//  Copyright © 2015 Insoftcan. All rights reserved.
//

import UIKit

class SlideOutAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey) {
            let duration = transitionDuration(transitionContext)
            let containerView = transitionContext.containerView()
            
            UIView.animateWithDuration(duration,
                animations: {
                    fromView.center.y -= containerView!.bounds.size.height
                    fromView.transform = CGAffineTransformMakeScale(0.5, 0.5)
                },
                completion: { finished in
                    transitionContext.completeTransition(finished)
                }
            )
        }
    }
}
