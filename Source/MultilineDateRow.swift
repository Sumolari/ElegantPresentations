//
//  MultilineDateRow.swift
//  Pods
//
//  Created by Lluís Ulzurrun on 13/7/16.
//
//

import Eureka

public class MultilineDateCell: Cell<NSDate>, CellType {

	lazy public var datePicker = UIDatePicker()

	public required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
	}

	public override func setup() {
		super.setup()

		NSLayoutConstraint.deactivateConstraints(textLabel?.constraints ?? [])
		NSLayoutConstraint.deactivateConstraints(detailTextLabel?.constraints ?? [])
		textLabel?.translatesAutoresizingMaskIntoConstraints = false
		detailTextLabel?.translatesAutoresizingMaskIntoConstraints = false

		let views = ["textLabel": textLabel!, "detailTextLabel": detailTextLabel!]

		let constraints =
			NSLayoutConstraint.constraintsWithVisualFormat("|-[textLabel]-|", options: [], metrics: [:], views: views) +
			NSLayoutConstraint.constraintsWithVisualFormat("V:|-[textLabel]-[detailTextLabel]-|", options: [], metrics: [:], views: views) +
			NSLayoutConstraint.constraintsWithVisualFormat("|-[detailTextLabel]-|", options: [], metrics: [:], views: views)
		contentView.addConstraints(constraints)

		accessoryType = .None
		editingAccessoryType = .None
		datePicker.datePickerMode = datePickerMode()
		datePicker.addTarget(self, action: #selector(MultilineDateCell.datePickerValueChanged(_:)), forControlEvents: .ValueChanged)
	}

	deinit {
		datePicker.removeTarget(self, action: nil, forControlEvents: .AllEvents)
	}

	public override func update() {
		super.update()

		selectionStyle = row.isDisabled ? .None : .Default
		datePicker.setDate(row.value ?? NSDate(), animated: row is CountDownPickerRow)
		datePicker.minimumDate = (row as? DatePickerRowProtocol)?.minimumDate
		datePicker.maximumDate = (row as? DatePickerRowProtocol)?.maximumDate
		if let minuteIntervalValue = (row as? DatePickerRowProtocol)?.minuteInterval {
			datePicker.minuteInterval = minuteIntervalValue
		}
	}

	public override func didSelect() {
		super.didSelect()
		row.deselect()
	}

	override public var inputView: UIView? {
		if let v = row.value {
			datePicker.setDate(v, animated: row is CountDownRow)
		}
		return datePicker
	}

	func datePickerValueChanged(sender: UIDatePicker) {
		row.value = sender.date
		detailTextLabel?.text = row.displayValueFor?(row.value)
	}

	private func datePickerMode() -> UIDatePickerMode {
		switch row {
		case is DateRow:
			return .Date
		case is TimeRow:
			return .Time
		case is DateTimeRow:
			return .DateAndTime
		case is CountDownRow:
			return .CountDownTimer
		default:
			return .Date
		}
	}

	public override func cellCanBecomeFirstResponder() -> Bool {
		return canBecomeFirstResponder()
	}

	public override func canBecomeFirstResponder() -> Bool {
		return !row.isDisabled;
	}
}

public class _MultilineDateFieldRow: Row<NSDate, MultilineDateCell>, DatePickerRowProtocol, NoValueDisplayTextConformance {

	/// The minimum value for this row's UIDatePicker
	public var minimumDate: NSDate?

	/// The maximum value for this row's UIDatePicker
	public var maximumDate: NSDate?

	/// The interval between options for this row's UIDatePicker
	public var minuteInterval: Int?

	/// The formatter for the date picked by the user
	public var dateFormatter: NSDateFormatter?

	public var noValueDisplayText: String? = " "

	required public init(tag: String?) {
		super.init(tag: tag)
		displayValueFor = { [unowned self] value in
			guard let val = value, let formatter = self.dateFormatter else { return nil }
			return formatter.stringFromDate(val)
		}
	}
}

public class _MultilineDateRow: _MultilineDateFieldRow {
	required public init(tag: String?) {
		super.init(tag: tag)
		dateFormatter = NSDateFormatter()
		dateFormatter?.timeStyle = .NoStyle
		dateFormatter?.dateStyle = .MediumStyle
		dateFormatter?.locale = NSLocale.currentLocale()
	}
}

/// A row with an NSDate as value where the user can select a date from a picker view.
public final class MultilineDateRow: _MultilineDateRow, RowType {
	required public init(tag: String?) {
		super.init(tag: tag)
		onCellHighlight { cell, row in
			let color = cell.detailTextLabel?.textColor
			row.onCellUnHighlight { cell, _ in
				cell.detailTextLabel?.textColor = color
			}
			cell.detailTextLabel?.textColor = cell.tintColor
		}
	}
}
