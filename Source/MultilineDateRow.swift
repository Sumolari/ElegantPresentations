//
//  MultilineDateRow.swift
//  Pods
//
//  Created by Lluís Ulzurrun on 13/7/16.
//
//

import Eureka

open class MultilineDateCell: Cell<Date>, CellType {

	lazy open var datePicker = UIDatePicker()

	public required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
	}
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

	open override func setup() {
		super.setup()

		NSLayoutConstraint.deactivate(self.textLabel?.constraints ?? [])
		NSLayoutConstraint.deactivate(self.detailTextLabel?.constraints ?? [])
		self.textLabel?.translatesAutoresizingMaskIntoConstraints = false
		self.detailTextLabel?.translatesAutoresizingMaskIntoConstraints = false

		let views = [
            "textLabel": self.textLabel!,
            "detailTextLabel": self.detailTextLabel!
        ]

		let constraints =
			NSLayoutConstraint.constraints(
                withVisualFormat: "|-[textLabel]-|",
                options: [],
                metrics: [:],
                views: views
            ) +
			NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-[textLabel]-[detailTextLabel]-|",
                options: [],
                metrics: [:],
                views: views
            ) +
			NSLayoutConstraint.constraints(
                withVisualFormat: "|-[detailTextLabel]-|",
                options: [],
                metrics: [:],
                views: views
            )
		self.contentView.addConstraints(constraints)

		self.accessoryType = .none
		self.editingAccessoryType = .none
		self.datePicker.datePickerMode = datePickerMode()
		self.datePicker.addTarget(
            self,
            action: #selector(MultilineDateCell.datePickerValueChanged(_:)),
            for: .valueChanged
        )
	}

	deinit {
		datePicker.removeTarget(self, action: nil, for: .allEvents)
	}

	open override func update() {
		super.update()

		self.selectionStyle = self.row.isDisabled ? .none : .default
		self.datePicker.setDate(
            self.row.value ?? Date(),
            animated: row is CountDownPickerRow
        )
		self.datePicker.minimumDate =
            (self.row as? DatePickerRowProtocol)?.minimumDate
		self.datePicker.maximumDate =
            (self.row as? DatePickerRowProtocol)?.maximumDate
		if let minuteIntervalValue = (self.row as? DatePickerRowProtocol)?.minuteInterval {
			self.datePicker.minuteInterval = minuteIntervalValue
		}
	}

	open override func didSelect() {
		super.didSelect()
		row.deselect()
	}

	override open var inputView: UIView? {
		if let v = row.value {
			datePicker.setDate(v, animated: row is CountDownRow)
		}
		return datePicker
	}

	func datePickerValueChanged(_ sender: UIDatePicker) {
		row.value = sender.date
		detailTextLabel?.text = row.displayValueFor?(row.value)
	}

	fileprivate func datePickerMode() -> UIDatePickerMode {
		switch row {
		case is DateRow:
			return .date
		case is TimeRow:
			return .time
		case is DateTimeRow:
			return .dateAndTime
		case is CountDownRow:
			return .countDownTimer
		default:
			return .date
		}
	}

	open override func cellCanBecomeFirstResponder() -> Bool {
		return !self.row.isDisabled
	}

}

open class _MultilineDateFieldRow: Row<MultilineDateCell>, DatePickerRowProtocol, NoValueDisplayTextConformance {

	/// The minimum value for this row's UIDatePicker
	open var minimumDate: Date?

	/// The maximum value for this row's UIDatePicker
	open var maximumDate: Date?

	/// The interval between options for this row's UIDatePicker
	open var minuteInterval: Int?

	/// The formatter for the date picked by the user
	open var dateFormatter: DateFormatter?

	open var noValueDisplayText: String? = " "

	required public init(tag: String?) {
		super.init(tag: tag)
		self.displayValueFor = { [unowned self] value in
			guard let val = value, let formatter = self.dateFormatter else { return nil }
			return formatter.string(from: val)
		}
	}
    
}

open class _MultilineDateRow: _MultilineDateFieldRow {
	required public init(tag: String?) {
		super.init(tag: tag)
		self.dateFormatter = DateFormatter()
		self.dateFormatter?.timeStyle = .none
		self.dateFormatter?.dateStyle = .medium
		self.dateFormatter?.locale = Locale.current
	}
}

/// A row with an NSDate as value where the user can select a date from a picker view.
public final class MultilineDateRow: _MultilineDateRow, RowType {
	required public init(tag: String?) {
		super.init(tag: tag)
        
        let color = cell.detailTextLabel?.textColor
        
		onCellHighlightChanged { cell, row in
            if row.isHighlighted {
                cell.detailTextLabel?.textColor = cell.tintColor
            } else {
                cell.detailTextLabel?.textColor = color
            }
		}
        
	}
}
