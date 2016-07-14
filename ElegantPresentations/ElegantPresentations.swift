//
//  ElegantPresentations.swift
//  TwitterPresentationController
//
//  Created by Kyle Bashour on 2/21/16.
//  Copyright © 2016 Kyle Bashour. All rights reserved.
//

import UIKit

/**
 *  Elegant modal presentations. Contains the function `controller` for creating presentation controllers.
 */
public struct ElegantPresentations {
    
    /**
     Initializes and returns an elegant presentation controller for transitioning between the specified view controllers.
     
     - parameter presentedViewController:  The view controller being presented modally.
     - parameter presentingViewController: The view controller whose content represents the starting point of the transition.
     - parameter options:                  An options set for customizing the appearance and behavior of the presentation.
     
     - returns: An initialized presentation controller object.
     */
    public static func controller(presentedViewController presented: UIViewController,
                presentingViewController presenting: UIViewController,
                options: Set<PresentationOption>) -> UIPresentationController
    {
        
        let options = PresentationOptions(options: options)
        
        return ElegantPresentationController(presentedViewController: presented, presentingViewController: presenting, options: options)
    }
}

// For storing the options set in the options array
struct PresentationOptions {
    var dimmingViewAlpha: CGFloat = 1
    var dimmingViewTapDismisses = false
    var presentingTransform = CGAffineTransformMakeScale(0.93, 0.93)
    var presentedHeight: CGFloat = -1
    var presentedPercentHeight = 1.0
    var presentedMaximumHeight: CGFloat = CGFloat.max
    var presentedMinimumHeight: CGFloat = 0
    var usePercentHeight = true
    var presentedWidth: CGFloat = -1
    var presentedPercentWidth = 1.0
    var presentedMaximumWidth: CGFloat = CGFloat.max
    var presentedMinimumWidth: CGFloat = 0
    var usePercentWidth = true
    
    init() { }
    
    init(options: Set<PresentationOption>) {
        for option in options {
            switch option {
            case .NoDimmingView: dimmingViewAlpha = 0
            case .CustomDimmingViewAlpha(let alpha): dimmingViewAlpha = alpha
            case .DismissOnDimmingViewTap: dimmingViewTapDismisses = true
            case .PresentingViewKeepsSize: presentingTransform = CGAffineTransformIdentity
            case .PresentedHeight(let height):
                usePercentHeight = false
                presentedHeight = height
            case .PresentedPercentHeight(let percentHeight):
                usePercentHeight = true
                presentedPercentHeight = percentHeight
            case .PresentedMaximumHeight(let maximumHeight):
                presentedMaximumHeight = maximumHeight
            case .PresentedMinimumHeight(let minimumHeight):
                presentedMinimumHeight = minimumHeight
            case .PresentedWidth(let width):
                usePercentWidth = false
                presentedWidth = width
            case .PresentedPercentWidth(let percentWidth):
                usePercentWidth = true
                presentedPercentWidth = percentWidth
            case .PresentedMaximumWidth(let maximumWidth):
                presentedMaximumWidth = maximumWidth
            case .PresentedMinimumWidth(let minimumWidth):
                presentedMinimumWidth = minimumWidth
            case .CustomPresentingScale(let scale):
                presentingTransform = CGAffineTransformMakeScale(CGFloat(min(1, scale)), CGFloat(min(1, scale)))
            }
        }
        
        // They tried to do both — bad!
        if presentedHeight != -1 && usePercentHeight {
            NSLog("\n-------------------------\nElegant Presentation Warning:\nDO NOT set a height and a percent height! Only one will be respected.\n-------------------------")
        }
        
        if presentedWidth != -1 && usePercentWidth {
            NSLog("\n-------------------------\nElegant Presentation Warning:\nDO NOT set a width and a percent width! Only one will be respected.\n-------------------------")
        }
        
        if options.contains(.NoDimmingView) &&  dimmingViewAlpha != 0 {
            NSLog("\n-------------------------\nElegant Presentation Warning:\nDO NOT set no dimming view and a custom dimming view alpha! Only one will be respected.\n-------------------------")
        }
        
        if presentedMaximumHeight < presentedMinimumHeight {
            NSLog("\n-------------------------\nElegant Presentation Warning:\nDO NOT set a maximum height lower than minimum height! Only one will be respected.\n-------------------------")
        }
        
        if presentedMaximumHeight < presentedMinimumHeight {
            NSLog("\n-------------------------\nElegant Presentation Warning:\nDO NOT set a maximum width lower than minimum width! Only one will be respected.\n-------------------------")
        }
        
    }
}

/**
 Options for customizing the presentation animations and behavior
 
 - NoDimmingView:           Do not dim the presenting view controller
 - DismissOnDimmingViewTap: Dismiss the presented view controller when the area outside its view is tapped
 - PresentingViewKeepsSize: Do not shrink the presenting view controller into the background
 - PresentedHeight:         Give the presented view controller a fixed height (may not work well with rotation)
 - PresentedMaximumHeight:  Give the presented view controller a fixed maximum height (may not work well with rotation)
 - PresentedMinimumHeight:  Give the presented view controller a fixed minimum height (may not work well with rotation)
 - PresentedPercentHeight:  Give the presented view controller a percent height of the presenting view controller (should work well with rotation)
 - PresentedWidth:          Give the presented view controller a fixed width (may not work well with rotation)
 - PresentedMaximumWidth:   Give the presented view controller a fixed maximum width (may not work well with rotation)
 - PresentedMinimumWidth:   Give the presented view controller a fixed minimum width (may not work well with rotation)
 - PresentedPercentWidth:   Give the presented view controller a percent width of the presenting view controller (should work well with rotation)
 */
public enum PresentationOption: Hashable {
    
    case NoDimmingView
    case CustomDimmingViewAlpha(CGFloat)
    case DismissOnDimmingViewTap
    case PresentingViewKeepsSize
    case PresentedHeight(CGFloat)
    case PresentedMaximumHeight(CGFloat)
    case PresentedMinimumHeight(CGFloat)
    case PresentedPercentHeight(Double)
    case PresentedWidth(CGFloat)
    case PresentedMaximumWidth(CGFloat)
    case PresentedMinimumWidth(CGFloat)
    case PresentedPercentWidth(Double)
    case CustomPresentingScale(Double)
    
    var description: String {
        switch self {
        case .NoDimmingView:                        return "No dimming view"
        case .CustomDimmingViewAlpha(let alpha):    return "Custom dimming view alpha \(alpha)"
        case .DismissOnDimmingViewTap:              return "Dismiss on dimming view tap"
        case .PresentingViewKeepsSize:              return "Presenting view keeps size"
        case .PresentedHeight(let height):          return "Presented height \(height)"
        case .PresentedPercentHeight(let percent):  return "Presented percent height \(percent)"
        case .PresentedMaximumHeight(let height):   return "Presented maximum height \(height)"
        case .PresentedMinimumHeight(let height):   return "Presented minimum height \(height)"
        case .PresentedWidth(let width):            return "Presented width \(width)"
        case .PresentedPercentWidth(let percent):   return "Presented percent width \(percent)"
        case .PresentedMaximumWidth(let width):     return "Presented maximum width \(width)"
        case .PresentedMinimumWidth(let width):     return "Presented minimum width \(width)"
        case .CustomPresentingScale(let scale):     return "Custom presenting scale \(scale)"
        }
    }
    
    public var hashValue: Int {
        return description.hashValue
    }
}

public func ==(lhs: PresentationOption, rhs: PresentationOption) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
