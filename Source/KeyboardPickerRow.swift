//
//  KeyboardPickerRow.swift
//  Pods
//
//  Created by Lluís Ulzurrun on 14/9/16.
//
//

import Eureka

open class KeyboardPickerCell<T>: Cell<T>, CellType, UIPickerViewDataSource, UIPickerViewDelegate where T: Equatable {

	open lazy var picker: PickerViewPresenter = { [unowned self] in
		let pickerViewPresenter = PickerViewPresenter()
		pickerViewPresenter.pickerDelegate = self
		pickerViewPresenter.pickerDataSource = self
		self.contentView.addSubview(pickerViewPresenter)
		return pickerViewPresenter
	}()

	fileprivate var pickerRow: KeyboardPickerRow<T>? {
		return row as? KeyboardPickerRow<T>
	}

	public required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
	}
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

	open override func setup() {
		super.setup()
		self.accessoryType = .none
		self.editingAccessoryType = .none
		self.picker.pickerDelegate = self
		self.picker.pickerDataSource = self
	}

	deinit {
		self.picker.pickerDelegate = nil
		self.picker.pickerDataSource = nil
	}

	open override func update() {
		super.update()

		self.textLabel?.text = self.pickerRow?.title
		self.detailTextLabel?.text =
            self.pickerRow?.displayValueFor?(self.pickerRow?.value)
		self.picker.reloadAllComponents()
		if let selectedValue = self.pickerRow?.value,
            let index = self.pickerRow?.options.index(of: selectedValue) {
			self.picker.selectRowAtIndex(index)
		}

	}

	open override func cellCanBecomeFirstResponder() -> Bool {
		return true
	}

	open override func cellBecomeFirstResponder(
        withDirection direction: Direction
    ) -> Bool {
		self.picker.pickerInputAccessoryView = self.inputAccessoryView
		self.picker.showPicker()
		return super.cellBecomeFirstResponder(withDirection: direction)
	}

	open override func cellResignFirstResponder() -> Bool {
		self.picker.hidePicker()
		return super.cellResignFirstResponder()
	}

	// MARK: User interaction

	open override func didSelect() {
		self.pickerRow?.deselect()
		self.cellBecomeFirstResponder(withDirection: .down)
	}

	// MARK: Picker

	open func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}

	open func pickerView(
        _ pickerView: UIPickerView,
        numberOfRowsInComponent component: Int
    ) -> Int {
		return self.pickerRow?.options.count ?? 0
	}

	open func pickerView(
        _ pickerView: UIPickerView,
        titleForRow row: Int,
        forComponent component: Int
    ) -> String? {
		return pickerRow?.displayValueFor?(self.pickerRow?.options[row])
	}

	open func pickerView(
        _ pickerView: UIPickerView,
        didSelectRow row: Int,
        inComponent component: Int
    ) {
		if let picker = self.pickerRow, !picker.options.isEmpty {
			picker.value = picker.options[row]
			self.detailTextLabel?.text = self.pickerRow?.displayValueFor?(
                pickerRow?.value
            )
		}
	}

}

/// A generic row where the user can pick an option from a picker view and the
/// picker replaces the keyboard
public final class KeyboardPickerRow<T>: Row<KeyboardPickerCell<T>>, RowType where T: Equatable {

	public var options = [T]()

	required public init(tag: String?) {
		super.init(tag: tag)
	}

}
