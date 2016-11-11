//
//  StringSearchable.swift
//  Pods
//
//  Created by Lluís Ulzurrun de Asanza Sàez on 26/6/16.
//
//

import Foundation

public protocol StringSearchable: Equatable {

	/**
	 Returns whether this object should be returned for a search with given term.

	 - parameter term Search query.
	 - return `true` if this item should be returned.
	 */
	func resultFor(term: String) -> Bool

}

extension String: StringSearchable {

	public func resultFor(term: String) -> Bool {

		if term.characters.count == 0 {
			return true;
		}

		let shorter: String
		let longer: String

		if self.characters.count > term.characters.count {
			shorter = term
			longer = self
		} else {
			shorter = self
			longer = term
		}

		return longer.lowercased().contains(shorter.lowercased())

	}

}
