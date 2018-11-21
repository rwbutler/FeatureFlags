//
//  PickerViewController.swift
//  FeatureFlags
//
//  Created by Ross Butler on 10/23/18.
//

import Foundation
import UIKit

class PickerViewController<PickerOption: Equatable & CustomStringConvertible>: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource {
    
    // MARK: Type definitions
    typealias PickerItemTapped = (PickerOption) -> Void
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var closeOverlay: UIControl!
    
    // MARK: State
    public var selection: PickerItemTapped? // Callback
    private var selectedItem: PickerOption?
    public var viewModel: [String: PickerOptionsViewModel<PickerOption>]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isScrollEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setSelectedRows()
    }
    
    @IBAction func dismiss() {
        guard selectedItem == nil else {
            self.dismiss(animated: false, completion: nil)
            return
        }
        if let selectedOption = viewModel?.values.first?.selectedOption() {
            selectedItem = selectedOption
            selection?(selectedOption)
        }
        self.dismiss(animated: false, completion: nil)
    }
    
    private func setSelectedRows() {
        guard let sectionTitles = viewModel?.keys.compactMap({ $0 }) else {
            return
        }
        var sectionCounter = 0
        let sectionViewModels = sectionTitles.compactMap({ return viewModel?[$0] })
        for sectionViewModel in sectionViewModels {
            for i in 0..<sectionViewModel.pickerOptions.count where
                sectionViewModel.pickerOptions[i] == sectionViewModel.pickerOptions[sectionViewModel.selectedIndex] {
                    let cell = tableView.cellForRow(at: IndexPath(row: 0, section: sectionCounter)) // Currently 1 row per section
                    let pickerTagOffset = sectionCounter
                    if let pickerView = cell?.viewWithTag(pickerTagOffset) as? UIPickerView {
                        pickerView.selectRow(i, inComponent: 0, animated: false)
                    }
                    break
            }
            sectionCounter += 1
        }
    }
    
    // MARK: UIPickerViewDataSource
    /// Note: Ordinarily this method would be in a UIPickerViewDataSource extension however @objc methods are unavailable in Swift extensions of generic classes.
    @objc func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    /// Note: Ordinarily this method would be in a UIPickerViewDataSource extension however @objc methods are unavailable in Swift extensions of generic classes.
    @objc func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let sectionKeys = viewModel?.keys.compactMap({ $0 }) ?? []
        let sectionKey = sectionKeys[pickerView.tag]
        let options = viewModel?[sectionKey]
        return options?.pickerOptions.count ?? 0
    }
    
    // MARK: UIPickerViewDelegate
    /// Ordinarily this method would be in a UIPickerViewDelegate extension however @objc methods are unavailable in Swift extensions of generic classes.
    @objc func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let sectionKeys = viewModel?.keys.compactMap({ $0 }) ?? []
        let sectionKey = sectionKeys[pickerView.tag]
        let options = viewModel?[sectionKey]
        return options?.pickerOptions[row].description ?? ""
    }
    /// Ordinarily this method would be in a UIPickerViewDelegate extension however @objc methods are unavailable in Swift extensions of generic classes.
    @objc func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let sectionKeys = viewModel?.keys.compactMap({ $0 }) ?? []
        let sectionKey = sectionKeys[pickerView.tag]
        let options = viewModel?[sectionKey]
        if let selectedPickerOption = options?.pickerOptions[row] {
            selectedItem = selectedPickerOption
            selection?(selectedPickerOption)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.keys.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "picker-cell", for: indexPath)
        if let pickerView = cell.viewWithTag(1) as? UIPickerView {
            pickerView.tag = indexPath.section
            pickerView.delegate = self
        }
        return cell
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = view as? UILabel
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "Avenir-Light", size: 24.0)
            pickerLabel?.textAlignment = .center
        }
        pickerLabel?.text = self.pickerView(pickerView, titleForRow: row, forComponent: component)
        return pickerLabel!
    }
}
