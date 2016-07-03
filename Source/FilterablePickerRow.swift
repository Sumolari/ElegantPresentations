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

public class FilterablePickerCell<T where T: StringSearchable> : Cell<T>, CellType, UIPickerViewDataSource, UIPickerViewDelegate {
    
    public lazy var filterField: UITextField = { [unowned self] in
        
        let filterField = UITextField()
        filterField.clearButtonMode = .Always
        filterField.placeholder = self.pickerRow?.filterHint
        filterField.addTarget(self, action: "textFieldDidChange:", forControlEvents: .EditingChanged)
        filterField.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(filterField)
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[filterField]-|", options: [], metrics: nil, views: ["filterField": filterField]))
        
        return filterField
        
    }()
    
    public lazy var picker: UIPickerView = { [unowned self] in
        
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(picker)
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[filterField]-[picker]-0-|", options: [], metrics: nil, views: ["filterField": self.filterField, "picker": picker]))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[picker]-0-|", options: [], metrics: nil, views: ["picker": picker]))
        
        return picker
    
    }()
    
    public var lastFilterApplied: String?
    
    public var filteredOptions: [T] = []
    
    private var pickerRow : FilterablePickerRow<T>? { return self.row as? FilterablePickerRow<T> }
    
    public required init(style: UITableViewCellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public override func setup() {
        super.setup()
        accessoryType = .None
        editingAccessoryType = .None
        self.picker.delegate = self
        self.picker.dataSource = self
        self.filteredOptions = self.pickerRow?.options ?? []
    }
    
    deinit {
        self.picker.delegate = nil
        self.picker.dataSource = nil
    }
    
    public override func update(){
        super.update()
        textLabel?.text = nil
        detailTextLabel?.text = nil
        self.picker.reloadAllComponents()
        if let selectedValue = self.pickerRow?.value, let index = self.pickerRow?.options.indexOf(selectedValue){
            self.picker.selectRow(index, inComponent: 0, animated: true)
        }
    }
    
    public func textFieldDidChange( textField: UITextField ) {
        updateResultsWithNewFilter(textField.text)
    }
    
    public func updateResultsWithNewFilter( filter: String? ) {
        
        guard filter != lastFilterApplied else {
            return
        }
        
        self.lastFilterApplied = filter
        
        if let newFilter = self.lastFilterApplied {
            self.filteredOptions = self.pickerRow?.options.filter { (item) -> Bool in
                return item.resultFor(term: newFilter)
            } ?? []
        } else {
            self.filteredOptions = self.pickerRow?.options ?? []
        }
        
        self.picker.reloadAllComponents()
        
        if self.filteredOptions.count == 1 {
            self.selectFilteredOption(0)
        } else if
            let picker = self.pickerRow where !picker.options.isEmpty,
            let value = picker.value,
            let row = self.filteredOptions.indexOf(value)
        {
            self.picker.selectRow(row, inComponent: 0, animated: true)
        }
        
    }
    
    public func selectFilteredOption( row: Int ) {
        if let picker = self.pickerRow where !picker.options.isEmpty {
            picker.value = self.filteredOptions[row]
        }
    }
    
    //MARK: Picker view delegate
    
    public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.filteredOptions.count ?? 0
    }
    
    public func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickerRow?.displayValueFor?(self.filteredOptions[row])
    }
    
    public func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectFilteredOption(row)
    }
    
}

//MARK: - Filterable Picker Row

public final class FilterablePickerRow<T: StringSearchable>: Row<T, FilterablePickerCell<T>>, RowType {
    
    public var options = [T]()
    public var filterHint = ""
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
    
}

//MARK: - Filterable Picker Inline Cell

public class FilterablePickerInlineCell<T: StringSearchable> : Cell<T>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    public override func setup() {
        super.setup()
        self.accessoryType = .None
        self.editingAccessoryType =  .None
    }
    
    public override func update() {
        super.update()
        self.selectionStyle = self.row.isDisabled ? .None : .Default
    }
    
    public override func didSelect() {
        super.didSelect()
        self.row.deselect()
    }
}

//MARK: - Filterable Picker Inline Row

public final class FilterablePickerInlineRow<T: StringSearchable>: Row<T, FilterablePickerInlineCell<T>>, RowType, InlineRowType, NoValueDisplayTextConformance {
    
    public typealias InlineRow = FilterablePickerRow<T>
    public var options = [T]()
    public var noValueDisplayText: String?
    public var filterHint = ""

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
    
    public func setupInlineRow(inlineRow: InlineRow) {
        inlineRow.options = self.options
        inlineRow.displayValueFor = self.displayValueFor
        inlineRow.filterHint = self.filterHint
    }
}
