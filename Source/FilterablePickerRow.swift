//
//  FilterablePickerRow.swift
//  Pods
//
//  Created by Lluís Ulzurrun de Asanza Sàez on 25/6/16.
//
//

import Foundation
import UIKit
import Eureka

//MARK: - Filterable Picker Cell

open class FilterablePickerCell<T>: Cell<T>, CellType, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate where T: Equatable {

	open lazy var filterField: UITextField = { [unowned self] in

		let filterField = UITextField()
		filterField.clearButtonMode = .always
		filterField.placeholder = self.pickerRow?.filterPlaceholder
		filterField.addTarget(self, action: "textFieldDidChange:", for: .editingChanged)
		filterField.translatesAutoresizingMaskIntoConstraints = false
		filterField.delegate = self
		self.contentView.addSubview(filterField)
		self.contentView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-[filterField]-|",
                options: [],
                metrics: nil,
                views: ["filterField": filterField]
            )
        )

		return filterField

	}()

	open lazy var picker: UIPickerView = { [unowned self] in

		let maxHeight = (UIApplication.shared.delegate?.window??.rootViewController?.view.frame.size.height ?? 0) * 0.25

		let picker = UIPickerView()
		picker.translatesAutoresizingMaskIntoConstraints = false
		self.contentView.addSubview(picker)
		self.contentView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-[filterField]-[picker(<=maxHeight)]-0-|",
                options: [],
                metrics: ["maxHeight": maxHeight],
                views: ["filterField": self.filterField, "picker": picker]
            )
        )
		self.contentView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-0-[picker]-0-|",
                options: [],
                metrics: nil,
                views: ["picker": picker]
            )
        )

		return picker

	}()

	open var lastFilterApplied: String?

	open var optionForNewEntry: ((String) -> (option: T, displayValue: String)?)? = nil

	open var filteredOptions: [T] = []

	fileprivate var pickerRow: FilterablePickerRow<T>? {
        return self.row as? FilterablePickerRow<T>
    }

	public required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
	}
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

	open override func setup() {
		super.setup()
		accessoryType = .none
		editingAccessoryType = .none
		self.picker.delegate = self
		self.picker.dataSource = self
		self.filteredOptions = self.pickerRow?.options ?? []
	}

	deinit {
		self.picker.delegate = nil
		self.picker.dataSource = nil
	}

	open override func update() {
		super.update()
		self.selectionStyle = .none
		textLabel?.text = nil
		detailTextLabel?.text = nil
		self.picker.reloadAllComponents()
		if let selectedValue = self.pickerRow?.value,
			let index = self.pickerRow?.options.index(of: selectedValue)
		{
			self.picker.selectRow(index, inComponent: 0, animated: true)
		}
	}

	open func textFieldDidChange(_ textField: UITextField) {
        self.updateResults(newFilter: textField.text)
	}

	open func shouldIncludeItem(_ item: T, term: String) -> Bool {
		return self.row.displayValueFor?(item)?.resultFor(term: term) ?? false
	}

	open func shouldIncludeItem<T>(_ item: T, term: String) -> Bool
    where T: StringSearchable {
		return item.resultFor(term: term)
	}

	open func updateResults(newFilter filter: String?, forced: Bool = false) {

		guard filter != lastFilterApplied || forced else {
			return
		}

		self.lastFilterApplied = filter

		if let newFilter = self.lastFilterApplied {

			self.filteredOptions = self.pickerRow?.options.filter {
                (item) -> Bool in
				return self.shouldIncludeItem(item, term: newFilter)
			} ?? []

			if let block = self.optionForNewEntry,
                let additionalOption = block(newFilter), newFilter != "" {
				self.filteredOptions = [additionalOption.option] + filteredOptions
			}

		} else {
			self.filteredOptions = self.pickerRow?.options ?? []
		}

		self.picker.reloadAllComponents()

		if self.filteredOptions.count == 1 {
			self.selectFilteredOption(0)
		} else if let picker = self.pickerRow,
			let value = picker.value,
			let row = self.filteredOptions.index(of: value),
            !picker.options.isEmpty {
			self.picker.selectRow(row, inComponent: 0, animated: true)
		}

	}

	open func selectFilteredOption(_ row: Int) {
		if let picker = self.pickerRow,
            !picker.options.isEmpty && row < self.filteredOptions.count {
			picker.value = self.filteredOptions[row]
		}
	}

	override open func cellCanBecomeFirstResponder() -> Bool {
		return true
	}

	// MARK: Picker view delegate

	open func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}

	open func pickerView(
        _ pickerView: UIPickerView,
        numberOfRowsInComponent component: Int
    ) -> Int {
		return self.filteredOptions.count ?? 0
	}

	open func pickerView(
		_ pickerView: UIPickerView,
		titleForRow row: Int,
		forComponent component: Int
	) -> String? {

		if let filter = self.lastFilterApplied,
			let block = self.optionForNewEntry,
			let tuple = block(filter), filter != "" && row == 0 {
			return tuple.displayValue
		}

		return self.pickerRow?.displayValueFor?(self.filteredOptions[row])
	}

	open func pickerView(
        _ pickerView: UIPickerView,
        didSelectRow row: Int,
        inComponent component: Int
    ) {
		self.selectFilteredOption(row)
	}

	// MARK: Text field delegate

	open func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if let v = self.formViewController()?.inputAccessoryView(for: row) as? NavigationAccessoryView {
			v.previousButton.isEnabled = false
			v.nextButton.isEnabled = false
			textField.inputAccessoryView = v
		}

	}

}

//MARK: - Filterable Picker Row

public final class FilterablePickerRow<T: Equatable>: Row<FilterablePickerCell<T>>, RowType {

	public var optionForNewEntry: ((String) -> (option: T, displayValue: String)?)? {
		get {
			return self.cell.optionForNewEntry
		}
		set {
			self.cell.optionForNewEntry = newValue
		}
	}

	public var options = [T]() {
		didSet {
			self.cell.updateResults(
                newFilter: self.cell.filterField.text,
				forced: true
			)
		}
	}

	public var filterPlaceholder: String? {
		didSet {
			self.cell.filterField.placeholder = self.filterPlaceholder
		}
	}

	required public init(tag: String?) {
		super.init(tag: tag)
	}

}

//MARK: - Filterable Picker Inline Cell

open class FilterablePickerInlineCell<T: Equatable>: Cell<T>, CellType {

	required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
	}
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

	open override func setup() {
		super.setup()
		self.accessoryType = .none
		self.editingAccessoryType = .none
	}

	open override func update() {
		super.update()
		self.selectionStyle = self.row.isDisabled ? .none : .default
	}

	open override func didSelect() {
		super.didSelect()
		self.row.deselect()
	}
}

//MARK: - Filterable Picker Inline Row

public final class FilterablePickerInlineRow<T: Equatable>: Row<FilterablePickerInlineCell<T>>, RowType, InlineRowType, NoValueDisplayTextConformance {

	public var optionForNewEntry: ((String) -> (option: T, displayValue: String)?)? {
		didSet {
			self.inlineRow?.optionForNewEntry = self.optionForNewEntry
		}
	}

	public typealias InlineRow = FilterablePickerRow<T>
	public var options = [T]() {
		didSet {
			self.inlineRow?.options = self.options
		}
	}
	public var noValueDisplayText: String?
	public var filterPlaceholder: String? {
		didSet {
			self.inlineRow?.filterPlaceholder = self.filterPlaceholder
		}
	}

	required public init(tag: String?) {
		super.init(tag: tag)
		self.onExpandInlineRow { cell, row, _ in
			let color = cell.detailTextLabel?.textColor
			row.onCollapseInlineRow { cell, _, _ in
				cell.detailTextLabel?.textColor = color
			}
			cell.detailTextLabel?.textColor = cell.tintColor
		}
	}

	public override func customDidSelect() {
		super.customDidSelect()
		if !self.isDisabled {
			self.toggleInlineRow()
		}
	}

	public func setupInlineRow(_ inlineRow: InlineRow) {
		inlineRow.options = self.options
		inlineRow.displayValueFor = self.displayValueFor
		inlineRow.filterPlaceholder = self.filterPlaceholder
		inlineRow.cell.selectionStyle = .none
		inlineRow.optionForNewEntry = self.optionForNewEntry
	}

	override public func customUpdateCell() {
		super.customUpdateCell()
		self.inlineRow?.customUpdateCell()
	}

}
