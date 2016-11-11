//
//  ViewController.swift
//  Demo
//
//  Created by Lluís Ulzurrun de Asanza Sàez on 25/6/16.
//  Copyright © 2016 Lluís Ulzurrun de Asanza i Sàez. All rights reserved.
//

import UIKit
import Eureka
import EurekaExtensions

class ViewController: FormViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		form
		+++ Section("Custom Date cells")
		<<< MultilineDateRow() {
			$0.title = "Date"
		}
		+++ Section("Custom Picker cells")
		<<< FilterablePickerRow<String>() {
			$0.title = "Picker"
			$0.options = ["One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen", "Seventeen", "Eighteen", "Nineteen", "Twenty"]
			$0.filterPlaceholder = "Filter..."
		}
		<<< FilterablePickerInlineRow<String>() {
			$0.title = "Picker"
			$0.options = ["One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen", "Seventeen", "Eighteen", "Nineteen", "Twenty"]
			$0.filterPlaceholder = "Filter..."
		}
        <<< KeyboardPickerRow<String>() {
            $0.title = "Picker"
            $0.options = ["One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen", "Seventeen", "Eighteen", "Nineteen", "Twenty"]
        }
		/*
		 <<< PickerInlineRow<String>(){
		 $0.title = "Pick inline"
		 $0.options = ["One", "Two", "Three"]
		 }
		 <<< TextFloatLabelRow() {
		 $0.title = "Float Label Row, type something to see.."
		 }
		 <<< TextRow() {
		 $0.title = "Title..."
		 }
		 */
	}

}

