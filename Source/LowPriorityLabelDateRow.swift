//
//  LowPriorityLabelDateRow.swift
//  Pods
//
//  Created by Lluís Ulzurrun on 13/7/16.
//
//

import Eureka

public class LowPriorityLabelDateCell: Cell<NSDate>, CellType {

	lazy public var datePicker = UIDatePicker()

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

	public override func setup() {
		super.setup()

		// textLabel?.setContentHuggingPriority(UILayoutPriorityDefaultLow, forAxis: .Horizontal)
		textLabel?.lineBreakMode = .ByTruncatingHead
		textLabel?.adjustsFontSizeToFitWidth = true

		// detailTextLabel?.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, forAxis: .Horizontal)

		accessoryType = .None
		editingAccessoryType = .None
		datePicker.datePickerMode = datePickerMode()
		datePicker.addTarget(self, action: #selector(LowPriorityLabelDateCell.datePickerValueChanged(_:)), forControlEvents: .ValueChanged)

		self.setNeedsUpdateConstraints()
	}

	public override func updateConstraints() {
		super.updateConstraints()

		guard let textLabel = self.textLabel, detailTextLabel = self.detailTextLabel
		where textLabel.superview === self.contentView && detailTextLabel.superview === self.contentView
		else { return }

		textLabel.translatesAutoresizingMaskIntoConstraints = false
		detailTextLabel.translatesAutoresizingMaskIntoConstraints = false

		var constraintsToBeAdded = [NSLayoutConstraint]()
		var constraintsToBeEnabled = [NSLayoutConstraint]()

		if let constraint = self.containerLeadingAnchorToTitleLabelLeadingConstraint {
			constraintsToBeEnabled.append(constraint)
		} else {
			let constraint = NSLayoutConstraint(
				attribute: .Leading,
				ofView: textLabel,
				equalToAttribute: .LeadingMargin,
				ofView: self.contentView
			)
			constraintsToBeAdded.append(constraint)
			self.containerLeadingAnchorToTitleLabelLeadingConstraint = constraint
		}

		if let constraint = self.containerTopAnchorToTitleLabelTopConstraint {
			constraintsToBeEnabled.append(constraint)
		} else {
			let constraint = NSLayoutConstraint(
				attribute: .Top,
				ofView: textLabel,
				equalToAttribute: .TopMargin,
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
				attribute: .Bottom,
				ofView: textLabel,
				equalToAttribute: .BottomMargin,
				ofView: self.contentView
			)
			constraintsToBeAdded.append(constraint)
			self.containerBottomAnchorToTitleLabelBottomConstraint = constraint
		}

		if let constraint = self.titleLabelTrailingToDateLabelLeadingConstraint {
			constraintsToBeEnabled.append(constraint)
		} else {
			let constraint = NSLayoutConstraint(
				attribute: .Trailing,
				ofView: textLabel,
				equalToAttribute: .Leading,
				ofView: detailTextLabel
			)
			constraintsToBeAdded.append(constraint)
			self.titleLabelTrailingToDateLabelLeadingConstraint = constraint
		}

		if let constraint = self.sameTopForTitleAndDateLabelsConstraint {
			constraintsToBeEnabled.append(constraint)
		} else {
			let constraint = NSLayoutConstraint(
				attribute: .Top,
				ofView: textLabel,
				equalToAttribute: .Top,
				ofView: detailTextLabel
			)
			constraintsToBeAdded.append(constraint)
			self.sameTopForTitleAndDateLabelsConstraint = constraint
		}

		if let constraint = self.sameBottomForTitleAndDateLabelsConstraint {
			constraintsToBeEnabled.append(constraint)
		} else {
			let constraint = NSLayoutConstraint(
				attribute: .Bottom,
				ofView: textLabel,
				equalToAttribute: .Bottom,
				ofView: detailTextLabel
			)
			constraintsToBeAdded.append(constraint)
			self.sameBottomForTitleAndDateLabelsConstraint = constraint
		}

		if let constraint = self.dateLabelTrailingToContainerTrailingAnchorConstraint {
			constraintsToBeEnabled.append(constraint)
		} else {
			let constraint = NSLayoutConstraint(
				attribute: .Trailing,
				ofView: detailTextLabel,
				equalToAttribute: .TrailingMargin,
				ofView: self.contentView
			)
			constraintsToBeAdded.append(constraint)
			self.dateLabelTrailingToContainerTrailingAnchorConstraint = constraint
		}

		self.contentView.addConstraints(constraintsToBeAdded)
		NSLayoutConstraint.activateConstraints(constraintsToBeEnabled)

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

		self.setNeedsUpdateConstraints()

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

public class _LowPriorityLabelDateFieldRow: Row<NSDate, LowPriorityLabelDateCell>, DatePickerRowProtocol, NoValueDisplayTextConformance {

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

public class _LowPriorityLabelDateRow: _LowPriorityLabelDateFieldRow {
	required public init(tag: String?) {
		super.init(tag: tag)
		dateFormatter = NSDateFormatter()
		dateFormatter?.timeStyle = .NoStyle
		dateFormatter?.dateStyle = .MediumStyle
		dateFormatter?.locale = NSLocale.currentLocale()
	}
}

/// A row with an NSDate as value where the user can select a date from a picker view.
public final class LowPriorityLabelDateRow: _LowPriorityLabelDateRow, RowType {
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
