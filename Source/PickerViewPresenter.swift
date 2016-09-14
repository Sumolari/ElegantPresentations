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

public class PickerViewPresenter: UITextField {

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

	public var pickerDelegate: UIPickerViewDelegate? {
		didSet {
			pickerView.delegate = pickerDelegate
		}
	}

	public var pickerDataSource: UIPickerViewDataSource? {
		didSet {
			pickerView.dataSource = pickerDataSource
		}
	}

	public var currentlySelectedRow: Int {
		return pickerView.selectedRowInComponent(0)
	}

	public func selectRowAtIndex(index: Int) {
		pickerView.selectRow(index, inComponent: 0, animated: true)
	}

	public func showPicker() {
		self.becomeFirstResponder()
	}

	public func hidePicker() {
		self.resignFirstResponder()
	}

	public func reloadAllComponents() {
		self.pickerView.reloadAllComponents()
	}

	// MARK: - Views

	private let pickerView = UIPickerView(frame: CGRect.zero)

	public var pickerInputAccessoryView: UIView? = nil

}
