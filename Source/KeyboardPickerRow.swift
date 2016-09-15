//
//  KeyboardPickerRow.swift
//  Pods
//
//  Created by Lluís Ulzurrun on 14/9/16.
//
//

import Eureka

public class KeyboardPickerCell<T where T: Equatable>: Cell<T>, CellType, UIPickerViewDataSource, UIPickerViewDelegate {

	public lazy var picker: PickerViewPresenter = { [unowned self] in
		let pickerViewPresenter = PickerViewPresenter()
		pickerViewPresenter.pickerDelegate = self
		pickerViewPresenter.pickerDataSource = self
		self.contentView.addSubview(pickerViewPresenter)
		return pickerViewPresenter
	}()

	private var pickerRow: KeyboardPickerRow<T>? {
		return row as? KeyboardPickerRow<T>
	}

	public required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
	}

	public override func setup() {
		super.setup()
		accessoryType = .None
		editingAccessoryType = .None
		picker.pickerDelegate = self
		picker.pickerDataSource = self
	}

	deinit {
		picker.pickerDelegate = nil
		picker.pickerDataSource = nil
	}

	public override func update() {
		super.update()

		textLabel?.text = pickerRow?.title
		detailTextLabel?.text = pickerRow?.displayValueFor?(pickerRow?.value)
		picker.reloadAllComponents()
		if let selectedValue = pickerRow?.value, let index = pickerRow?.options.indexOf(selectedValue) {
			picker.selectRowAtIndex(index)
		}

	}

	public override func cellCanBecomeFirstResponder() -> Bool {
		return true
	}

	public override func cellBecomeFirstResponder(direction: Direction) -> Bool {
		picker.pickerInputAccessoryView = inputAccessoryView
		picker.showPicker()
		return super.cellBecomeFirstResponder(direction)
	}

	public override func cellResignFirstResponder() -> Bool {
		picker.hidePicker()
		return super.cellResignFirstResponder()
	}

	// MARK: User interaction

	public override func didSelect() {
		pickerRow?.deselect()
		self.cellBecomeFirstResponder(.Down)
	}

	// MARK: Picker

	public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
		return 1
	}

	public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return pickerRow?.options.count ?? 0
	}

	public func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		return pickerRow?.displayValueFor?(pickerRow?.options[row])
	}

	public func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		if let picker = pickerRow where !picker.options.isEmpty {
			picker.value = picker.options[row]
			detailTextLabel?.text = pickerRow?.displayValueFor?(pickerRow?.value)
		}
	}

}

/// A generic row where the user can pick an option from a picker view and the
/// picker replaces the keyboard
public final class KeyboardPickerRow<T where T: Equatable>: Row<T, KeyboardPickerCell<T>>, RowType {

	public var options = [T]()

	required public init(tag: String?) {
		super.init(tag: tag)
	}

}