//
//  LowPriorityLabelDateRow.swift
//  Pods
//
//  Created by Lluís Ulzurrun on 13/7/16.
//
//

import Eureka

open class LowPriorityLabelDateCell: Cell<Date>, CellType {

	lazy open var datePicker = UIDatePicker()

	var containerLeadingAnchorToTitleLabelLeadingConstraint: NSLayoutConstraint? = nil
	var containerTopAnchorToTitleLabelTopConstraint: NSLayoutConstraint? = nil
	var containerBottomAnchorToTitleLabelBottomConstraint: NSLayoutConstraint? = nil
	var titleLabelTrailingToDateLabelLeadingConstraint: NSLayoutConstraint? = nil
	var sameTopForTitleAndDateLabelsConstraint: NSLayoutConstraint? = nil
	var sameBottomForTitleAndDateLabelsConstraint: NSLayoutConstraint? = nil
	var dateLabelTrailingToContainerTrailingAnchorConstraint: NSLayoutConstraint? = nil

	public required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: NSStringFromClass(LowPriorityLabelDateCell))
	}
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

	open override func setup() {
		super.setup()

		// textLabel?.setContentHuggingPriority(UILayoutPriorityDefaultLow, forAxis: .Horizontal)
		self.textLabel?.lineBreakMode = .byTruncatingHead
		self.textLabel?.adjustsFontSizeToFitWidth = true

		// detailTextLabel?.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, forAxis: .Horizontal)

		self.accessoryType = .none
		self.editingAccessoryType = .none
		self.datePicker.datePickerMode = self.datePickerMode()
		self.datePicker.addTarget(
            self,
            action: #selector(self.datePickerValueChanged(_:)),
            for: .valueChanged
        )

		self.setNeedsUpdateConstraints()
	}

	open override func updateConstraints() {
		super.updateConstraints()

		guard let textLabel = self.textLabel,
            let detailTextLabel = self.detailTextLabel,
            textLabel.superview === self.contentView &&
            detailTextLabel.superview === self.contentView
		else { return }

		textLabel.translatesAutoresizingMaskIntoConstraints = false
		detailTextLabel.translatesAutoresizingMaskIntoConstraints = false

		var constraintsToBeAdded = [NSLayoutConstraint]()
		var constraintsToBeEnabled = [NSLayoutConstraint]()

		if let constraint = self.containerLeadingAnchorToTitleLabelLeadingConstraint {
			constraintsToBeEnabled.append(constraint)
		} else {
			let constraint = NSLayoutConstraint(
				attribute: .leading,
				ofView: textLabel,
				equalToAttribute: .leadingMargin,
				ofView: self.contentView
			)
			constraintsToBeAdded.append(constraint)
			self.containerLeadingAnchorToTitleLabelLeadingConstraint = constraint
		}

		if let constraint = self.containerTopAnchorToTitleLabelTopConstraint {
			constraintsToBeEnabled.append(constraint)
		} else {
			let constraint = NSLayoutConstraint(
				attribute: .top,
				ofView: textLabel,
				equalToAttribute: .topMargin,
				ofView: self.contentView
			)
			constraint.priority = UILayoutPriorityDefaultHigh
			constraintsToBeAdded.append(constraint)
			self.containerTopAnchorToTitleLabelTopConstraint = constraint
		}

		if let constraint = self.containerBottomAnchorToTitleLabelBottomConstraint {
			constraintsToBeEnabled.append(constraint)
		} else {
			let constraint = NSLayoutConstraint(
				attribute: .bottom,
				ofView: textLabel,
				equalToAttribute: .bottomMargin,
				ofView: self.contentView
			)
			constraintsToBeAdded.append(constraint)
			self.containerBottomAnchorToTitleLabelBottomConstraint = constraint
		}

		if let constraint = self.titleLabelTrailingToDateLabelLeadingConstraint {
			constraintsToBeEnabled.append(constraint)
		} else {
			let constraint = NSLayoutConstraint(
				attribute: .trailing,
				ofView: textLabel,
				equalToAttribute: .leading,
				ofView: detailTextLabel
			)
			constraintsToBeAdded.append(constraint)
			self.titleLabelTrailingToDateLabelLeadingConstraint = constraint
		}

		if let constraint = self.sameTopForTitleAndDateLabelsConstraint {
			constraintsToBeEnabled.append(constraint)
		} else {
			let constraint = NSLayoutConstraint(
				attribute: .top,
				ofView: textLabel,
				equalToAttribute: .top,
				ofView: detailTextLabel
			)
			constraintsToBeAdded.append(constraint)
			self.sameTopForTitleAndDateLabelsConstraint = constraint
		}

		if let constraint = self.sameBottomForTitleAndDateLabelsConstraint {
			constraintsToBeEnabled.append(constraint)
		} else {
			let constraint = NSLayoutConstraint(
				attribute: .bottom,
				ofView: textLabel,
				equalToAttribute: .bottom,
				ofView: detailTextLabel
			)
			constraintsToBeAdded.append(constraint)
			self.sameBottomForTitleAndDateLabelsConstraint = constraint
		}

		if let constraint = self.dateLabelTrailingToContainerTrailingAnchorConstraint {
			constraintsToBeEnabled.append(constraint)
		} else {
			let constraint = NSLayoutConstraint(
				attribute: .trailing,
				ofView: detailTextLabel,
				equalToAttribute: .trailingMargin,
				ofView: self.contentView
			)
			constraintsToBeAdded.append(constraint)
			self.dateLabelTrailingToContainerTrailingAnchorConstraint = constraint
		}

		self.contentView.addConstraints(constraintsToBeAdded)
		NSLayoutConstraint.activate(constraintsToBeEnabled)

	}

	deinit {
		self.datePicker.removeTarget(self, action: nil, for: .allEvents)
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

		self.setNeedsUpdateConstraints()

	}

	open override func didSelect() {
		super.didSelect()
		self.row.deselect()
	}

	override open var inputView: UIView? {
		if let v = self.row.value {
			self.datePicker.setDate(v, animated: row is CountDownRow)
		}
		return self.datePicker
	}

	func datePickerValueChanged(_ sender: UIDatePicker) {
		self.row.value = sender.date
		self.detailTextLabel?.text = self.row.displayValueFor?(self.row.value)
	}

	fileprivate func datePickerMode() -> UIDatePickerMode {
		switch self.row {
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

open class _LowPriorityLabelDateFieldRow: Row<LowPriorityLabelDateCell>, DatePickerRowProtocol, NoValueDisplayTextConformance {

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
		displayValueFor = { [unowned self] value in
			guard let val = value, let formatter = self.dateFormatter else { return nil }
            return formatter.string(from: val)
		}
	}
}

open class _LowPriorityLabelDateRow: _LowPriorityLabelDateFieldRow {
	required public init(tag: String?) {
		super.init(tag: tag)
		self.dateFormatter = DateFormatter()
		self.dateFormatter?.timeStyle = .none
		self.dateFormatter?.dateStyle = .medium
		self.dateFormatter?.locale = Locale.current
	}
}

/// A row with an NSDate as value where the user can select a date from a picker view.
public final class LowPriorityLabelDateRow: _LowPriorityLabelDateRow, RowType {
	required public init(tag: String?) {
		super.init(tag: tag)
        let color = cell.detailTextLabel?.textColor
		self.onCellHighlightChanged { cell, row in
            if row.isHighlighted {
                cell.detailTextLabel?.textColor = cell.tintColor
            } else {
                cell.detailTextLabel?.textColor = color
            }
		}
	}
}
