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
			$0.options = ["One", "Two", "Three"]
			$0.filterHint = "Filter..."
		}
		<<< FilterablePickerInlineRow<String>() {
			$0.title = "Picker"
			$0.options = ["One", "Two", "Three"]
			$0.filterHint = "Filter..."
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

