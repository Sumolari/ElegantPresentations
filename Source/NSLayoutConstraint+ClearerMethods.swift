//
//  NSLayoutConstraint+ClearerMethods.swift
//  Pods
//
//  Created by Lluís Ulzurrun on 27/7/16.
//
//

import UIKit

extension NSLayoutConstraint {

	/**
	 Returns a constraint that will make both attributes equal for given views.

	 - parameter attribute: Attribute to be make equal.
	 - parameter fromView:  From view.
	 - parameter toView:    To view.

	 - returns: New constraint that will make given attribute equal for both
	 views.
	 */
	convenience init(
		sameAttribute attribute: NSLayoutAttribute,
		forView fromView: UIView,
		andView toView: UIView
	) {
		self.init(
			item: fromView,
			attribute: attribute,
			relatedBy: .equal,
			toItem: toView,
			attribute: attribute,
			multiplier: 1,
			constant: 0
		)
	}

	/**
	 Returns a constraint that will make first given attribute equal to second
	 given attribute for first and second given views, respectively.

	 - parameter attribute:         Attribute of first view to be considered.
	 - parameter ofView:            First view of the constraint.
	 - parameter equalToAttribute:  Attribute of second view to be considered.
	 - parameter ofView:            Second view of the constraint.

	 - returns: Constraint that will make both attributes equal to each other.
	 */
	convenience init(
		attribute fromViewAttribute: NSLayoutAttribute,
		ofView fromView: UIView,
		equalToAttribute toViewAttribute: NSLayoutAttribute,
		ofView toView: UIView
	) {
		self.init(
			item: fromView,
			attribute: fromViewAttribute,
			relatedBy: .equal,
			toItem: toView,
			attribute: toViewAttribute,
			multiplier: 1,
			constant: 0
		)
	}

}
