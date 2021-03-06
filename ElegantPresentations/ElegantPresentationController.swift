//
//  ElegantPresentation.swift
//  TwitterPresentationController
//
//  Created by Kyle Bashour on 2/21/16.
//  Copyright © 2016 Kyle Bashour. All rights reserved.
//

import UIKit

typealias CoordinatedAnimation = (UIViewControllerTransitionCoordinatorContext?) -> Void

class ElegantPresentationController: UIPresentationController, UIGestureRecognizerDelegate {
    
    
    // MARK: - Properties
    
    /// Dims the presenting view controller, if option is set
    private lazy var dimmingView: UIView = {
        
        let view = UIView()
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.alpha = 0
        view.isUserInteractionEnabled = false
        
        return view
    }()

    /// For dismissing on tap if option is set
    private lazy var recognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismiss))

    /// An options struct containing the customization options set
    private let options: PresentationOptions
    
    
    // MARK: - Lifecycle
    
    /**
     Initializes and returns a presentation controller for transitioning between the specified view controllers
     
     - parameter presentedViewController:  The view controller being presented modally.
     - parameter presentingViewController: The view controller whose content represents the starting point of the transition.
     - parameter options:                  An options struct for customizing the appearance and behavior of the presentation.
     
     - returns: An initialized presentation controller object.
     */
    init(presentedViewController: UIViewController, presentingViewController: UIViewController?, options: PresentationOptions) {
        self.options = options
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    
    // MARK: - Presenting and dismissing
    
    override func presentationTransitionWillBegin() {
        
        // If the option is set, then add the gesture recognizer for dismissal to the container
        if options.dimmingViewTapDismisses {
            recognizer.delegate = self
            containerView!.addGestureRecognizer(recognizer)
        }
        
        // Prepare and position the dimming view
        dimmingView.alpha = 0
        dimmingView.frame = containerView!.bounds
        containerView?.insertSubview(dimmingView, at: 0)
        
        // Animate these properties with the transtion coordinator if possible
        let animations: CoordinatedAnimation = { [unowned self] _ in
            self.dimmingView.alpha = self.options.dimmingViewAlpha
            self.presentingViewController.view.transform = self.options.presentingTransform
        }
        
        transtionWithCoordinator(animations)
    }
    
    override func dismissalTransitionWillBegin() {
        
        // Animate these properties with the transtion coordinator if possible
        let animations: CoordinatedAnimation = { [unowned self] _ in
            self.dimmingView.alpha = 0
            self.presentingViewController.view.transform = .identity
        }
        
        transtionWithCoordinator(animations)
    }
    
    
    // MARK: - Adaptation
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        /* 
         There's a bug when rotating that makes the presented view controller permanently 
         larger or smaller if this isn't here. I'm probably doing something wrong :P
         
         It jumps because it's not in the animation block, but isn't noticiable unless in 
         slow-mo. Placing it in the animation block does not fix the issue, so here it is.
        */
        presentingViewController.view.transform = .identity
        
        // Animate these with the coordinator
        let animations: CoordinatedAnimation = { [unowned self] _ in
            self.dimmingView.frame = self.containerView!.bounds
            self.presentingViewController.view.transform = self.options.presentingTransform
            self.presentedView?.frame = self.frameOfPresentedViewInContainerView
        }
        
        coordinator.animate(alongsideTransition: animations, completion: nil)
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        
        // Percent height doesn't make sense as a negative value or greater than one, so we'll enforce it
        let percentHeight = min(abs(options.presentedPercentHeight), 1)

        let height: CGFloat
        // Return the appropiate height based on which option is set
        if options.usePercentHeight {
            height = parentSize.height * CGFloat(percentHeight)
        } else if options.presentedHeight > 0 {
            height = options.presentedHeight
        } else {
            height = parentSize.height
        }
        
        // Percent width doesn't make sense as a negative value or greater than one, so we'll enforce it
        let percentWidth = min(abs(options.presentedPercentWidth), 1)
        
        let width: CGFloat
        // Return the appropiate width based on which option is set
        if options.usePercentWidth {
            width = parentSize.width * CGFloat(percentWidth)
        } else if options.presentedWidth > 0 {
            width = options.presentedWidth
        } else {
            width = parentSize.width
        }
        
        let clampedWidth  = max(min(width, options.presentedMaximumWidth), options.presentedMinimumWidth)
        let clampedHeight = max(min(height, options.presentedMaximumHeight), options.presentedMinimumHeight)
        
        return CGSize(width: clampedWidth, height: clampedHeight)
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        
        // Grab the parent and child sizes
        let parentSize = containerView!.bounds.size
        let childSize = size(forChildContentContainer: presentedViewController, withParentContainerSize: parentSize)
        
        // Create and return an appropiate frame
        return CGRect(x: 0, y: parentSize.height - childSize.height, width: childSize.width, height: childSize.height)
    }
    
    
    // MARK: - Helper functions
    
    // For the tap-to-dismiss
    func dismiss(_ sender: UITapGestureRecognizer) {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    /*
     I noticed myself doing this a lot (more so in earlier versions) so I made a quick function.
     Simply takes a closure with animations in them and attempts to animate with the coordinator.
    */
    private func transtionWithCoordinator(_ animations: @escaping CoordinatedAnimation) {
        if let coordinator = presentingViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: animations, completion: nil)
        }
        else {
            animations(nil)
        }
    }

    // MARK: UIGestureRecognizerDelegate protocol methods

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let pointInPresentedView = touch.location(in: presentedViewController.view)
        return !presentedViewController.view.bounds.contains(pointInPresentedView)
    }

}
