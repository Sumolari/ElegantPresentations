//
//  PickerViewPresenter.swift
//  Pods
//
//  Created by Lluís Ulzurrun on 14/9/16.
//
//  Based on answer by CodeMonkey: http://stackoverflow.com/a/36209431
//
//

import Foundation
import UIKit

open class PickerViewPresenter: UITextField {

	// MARK: - Initialization

	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public init() {
		super.init(frame: CGRect.zero)
		inputView = pickerView
		inputAccessoryView = pickerInputAccessoryView
	}

	// MARK: - Public

	open var pickerDelegate: UIPickerViewDelegate? {
		didSet {
			pickerView.delegate = pickerDelegate
		}
	}

	open var pickerDataSource: UIPickerViewDataSource? {
		didSet {
			pickerView.dataSource = pickerDataSource
		}
	}

	open var currentlySelectedRow: Int {
		return pickerView.selectedRow(inComponent: 0)
	}

	open func selectRowAtIndex(_ index: Int) {
		pickerView.selectRow(index, inComponent: 0, animated: true)
	}

	open func showPicker() {
		self.becomeFirstResponder()
	}

	open func hidePicker() {
		self.resignFirstResponder()
	}

	open func reloadAllComponents() {
		self.pickerView.reloadAllComponents()
	}

	// MARK: - Views

	fileprivate let pickerView = UIPickerView(frame: CGRect.zero)

	open var pickerInputAccessoryView: UIView? = nil

}
