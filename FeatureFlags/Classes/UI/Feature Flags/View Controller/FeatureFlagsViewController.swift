//
//  FeatureFlagsViewController.swift
//  FeatureFlags
//
//  Created by Ross Butler on 10/19/18.
//

#if canImport(UIKit)
import Foundation
import UIKit

class FeatureFlagsViewController: UITableViewController {
    
    // MARK: Type definitions
    public typealias Delegate = FeatureFlagsViewControllerDelegate
    public typealias NavigationSettings = ViewControllerNavigationSettings
    
    // MARK: State
    weak var delegate: Delegate?
    var navigationSettings: NavigationSettings?
    let viewModel = FeatureFlagsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Feature Flags"
        configureView()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellReuseIdentifier = String(describing: FeatureFlagTableViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        guard let feature = viewModel.feature(for: indexPath),
            let featureFlagCell = cell as? FeatureFlagTableViewCell else {
            return cell
        }
        return bindCell(featureFlagCell, feature: feature)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.sectionTitle(for: section)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }
    
    private func bindCell(_ cell: FeatureFlagTableViewCell, feature: Feature) -> FeatureFlagTableViewCell {
        cell.featureDetailButton.touchUpInside.action = {
            let viewController = FeatureDetailsViewController(style: .grouped)
            viewController.feature = feature
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        let testVariation = feature.testVariation()
        cell.featureName.text = feature.name.rawValue
        if let description = feature.detailText {
            cell.featureDescription.text = description
            cell.featureDescription.isHidden = false
            cell.featureDescriptionHeight.constant = cell.featureDescription.intrinsicContentSize.height
            cell.bottomMargin.constant = 10
        } else {
            cell.bottomMargin.constant = 0
            cell.featureDescriptionHeight.constant = 0
            cell.featureDescription.isHidden = true
        }
        cell.featureEnabled.isOn = feature.isEnabled()
        cell.featureType.text = feature.type.description
        let unlockedDescription = feature.isUnlocked() ? "Unlocked" : "Locked"
        cell.testVariation.text = feature.type == .unlockFlag ? unlockedDescription : testVariation.description
        let allLabels = [cell.featureName, cell.featureType, cell.featureDescription, cell.testVariation]
        
        let labelTextColor: UIColor
        
        if let iconName = feature.iconName {
            cell.iconView.image = UIImage(named: iconName, in: currentBundle(), compatibleWith: nil)
            cell.iconView.isHidden = false
        } else {
            cell.iconView.isHidden = true
        }
        
        switch feature.type {
        case .unlockFlag:
            labelTextColor = UIColor.white
            cell.contentView.backgroundColor = feature.isUnlocked()
                ? UIColor.featureFlagsGreen
                : UIColor.featureFlagsRed
            cell.iconView.tintColor = UIColor.white
        case .featureFlag, .featureTest(.featureFlagAB):
            labelTextColor = UIColor.white
            cell.contentView.backgroundColor = feature.isEnabled()
                ? UIColor.featureFlagsGreen
                : UIColor.featureFlagsRed
            cell.iconView.tintColor = UIColor.white
        case .featureTest(.ab), .featureTest(.mvt), .deprecated:
            cell.iconView.tintColor = UIColor.black
            labelTextColor = UIColor.black
            cell.contentView.backgroundColor = UIColor.white
        }
        allLabels.forEach({ label in
            label?.textColor = labelTextColor
        })
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.deleteFeature(at: indexPath)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: UITableViewDelegate
extension FeatureFlagsViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard var feature = viewModel.feature(for: indexPath) else {
            return
        }
        switch feature.type {
        case .featureTest(.ab):
            if let alternateABVariant = feature.testVariations.filter({ $0 != feature.testVariation() }).first {
                FeatureFlags.updateFeatureTestVariation(feature: feature.name, testVariation: alternateABVariant)
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
        case .featureFlag, .featureTest(.featureFlagAB):
            FeatureFlags.updateFeatureIsEnabled(feature: feature.name, isEnabled: !feature.isEnabled())
            tableView.reloadRows(at: [indexPath], with: .fade)
        case .featureTest(.mvt):
            presentPickerViewController(on: self, with: feature)
        case .unlockFlag:
            feature.setUnlocked(!feature.isUnlocked())
            tableView.reloadRows(at: [indexPath], with: .fade)
        case .deprecated:
            break
        }
    }
}

private extension FeatureFlagsViewController {
    
    private func configureNavigationBar() {
        let actionButtonType = navigationSettings?.actionButton ?? .action
        let closeButtonType = navigationSettings?.closeButton ?? .done
        let doneButton = UIBarButtonItem(barButtonSystemItem: closeButtonType,
                                         target: self,
                                         action: #selector(close))
        let actionButton = UIBarButtonItem(barButtonSystemItem: actionButtonType,
                                           target: self,
                                           action: #selector(presentActionSheet(_:)))
        let closeButtonAlignment = navigationSettings?.closeButtonAlignment ?? .closeButtonLeftActionButtonRight
        switch closeButtonAlignment {
        case .closeButtonLeftActionButtonRight:
            navigationItem.leftBarButtonItem = doneButton
            navigationItem.rightBarButtonItem = actionButton
        case .closeButtonRightActionButtonLeft:
            navigationItem.leftBarButtonItem = actionButton
            navigationItem.rightBarButtonItem = doneButton
        case .noCloseButtonActionButtonLeft:
            navigationItem.leftBarButtonItem = actionButton
        case .noCloseButtonActionButtonRight:
            navigationItem.rightBarButtonItem = actionButton
        }
        navigationItem.leftItemsSupplementBackButton = true
    }
    
    private func configureTableView() {
        let cellReuseIdentifier = String(describing: FeatureFlagTableViewCell.self)
        let cellNib = UINib(nibName: cellReuseIdentifier, bundle: Bundle(for: type(of: self)))
        tableView.register(cellNib, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableView.automaticDimension
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshFeatures(_:)), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else if let refreshControl = self.refreshControl {
            tableView.addSubview(refreshControl)
        }
        registerForPreviewing(with: self, sourceView: tableView)
    }
    
    @objc func refreshFeatures(_ sender: UIRefreshControl?) {
        guard sender != nil else {
            self.tableView.reloadData()
            return
        }
        FeatureFlags.refresh {
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
    
    func configureView() {
        configureNavigationBar()
        configureTableView()
    }
    
    @objc func close() {
        if viewControllerShouldDismiss() {
            let isAnimated: Bool = navigationSettings?.animated ?? true
            let isModal: Bool = navigationSettings?.isModal ?? (navigationController == nil)
            
            if isModal {
                dismiss(animated: isAnimated, completion: nil)
            } else {
                hideNavigationBarIfNeeded()
                navigationController?.popViewController(animated: isAnimated)
            }
        }
        delegate?.viewControllerDidFinish()
    }
    
    /// Presents the action sheet to be displayed in response to right bar button item touched.
    @objc func presentActionSheet(_ sender: UIBarButtonItem) {
        let actionSheet = menuAlertController(sender)
        if UIDevice.current.userInterfaceIdiom == .pad {
            actionSheet.modalPresentationStyle = .popover
            let popoverController = actionSheet.popoverPresentationController
            popoverController?.barButtonItem = sender
            popoverController?.permittedArrowDirections = .up
        }
        present(actionSheet, animated: true, completion: nil)
    }
    
    /// Presents the action sheet to be displayed in response to Filter By Section option selected.
    @objc func presentFilterBySectionActionSheet(_ sender: UIBarButtonItem) {
        let actionSheet = filterBySectionAlertController(sender)
        if UIDevice.current.userInterfaceIdiom == .pad {
            actionSheet.modalPresentationStyle = .popover
            let popoverController = actionSheet.popoverPresentationController
            popoverController?.barButtonItem = sender
            popoverController?.permittedArrowDirections = .up
        }
        present(actionSheet, animated: true, completion: nil)
    }
    
    /// Presents the action sheet to be displayed in response to Filter By Type option selected.
    @objc func presentFilterByTypeActionSheet(_ sender: UIBarButtonItem) {
        let actionSheet = filterByTypeAlertController(sender)
        if UIDevice.current.userInterfaceIdiom == .pad {
            actionSheet.modalPresentationStyle = .popover
            let popoverController = actionSheet.popoverPresentationController
            popoverController?.barButtonItem = sender
            popoverController?.permittedArrowDirections = .up
        }
        present(actionSheet, animated: true, completion: nil)
    }
    
    /// Returns action sheet to be presented in response to right bar button item touched.
    /// - returns: A UIAlertController to be presented as an action sheet.
    private func menuAlertController(_ sender: UIBarButtonItem) -> UIAlertController {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let clearCache = UIAlertAction(title: "Clear cache", style: .destructive) { _ in
            FeatureFlags.clearCache()
            FeatureFlags.refresh {
                self.dismiss(animated: true, completion: nil)
                self.tableView.reloadData()
            }
        }
        actionSheet.addAction(clearCache)
        if viewModel.filterIsApplied() {
            let clearFilters = UIAlertAction(title: "Clear filters", style: .default) { _ in
                self.viewModel.clearFilters()
                FeatureFlags.refresh {
                    self.dismiss(animated: true, completion: nil)
                    self.tableView.reloadData()
                }
            }
            actionSheet.addAction(clearFilters)
        }
        if FeatureFlags.sections().count != 1 {
            let filterBySection = UIAlertAction(title: "Filter by section", style: .default) { _ in
                self.dismiss(animated: true, completion: nil)
                self.presentFilterBySectionActionSheet(sender)
            }
            actionSheet.addAction(filterBySection)
        }
        let filterByType = UIAlertAction(title: "Filter by type", style: .default) { _ in
            self.dismiss(
                animated: true, completion: nil)
            self.presentFilterByTypeActionSheet(sender)
        }
        actionSheet.addAction(filterByType)
        let refresh = UIAlertAction(title: "Refresh", style: .default) { _ in
            FeatureFlags.refresh {
                self.dismiss(animated: true, completion: nil)
                self.tableView.reloadData()
            }
        }
        actionSheet.addAction(refresh)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        })
        actionSheet.addAction(cancel)
        return actionSheet
    }
    
    /// Returns action sheet to be presented in response to filter menu option selected.
    /// - returns: A UIAlertController to be presented as an action sheet.
    private func filterBySectionAlertController(_ sender: UIBarButtonItem) -> UIAlertController {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        viewModel.filtersBySection().forEach { filter in
            let filterOption = UIAlertAction(title: filter.name, style: .default) { _ in
                self.dismiss(animated: true, completion: nil)
                self.viewModel.applyFilter(filter)
                self.tableView.reloadData()
            }
            actionSheet.addAction(filterOption)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            self.dismiss(animated: true, completion: nil)
            self.presentActionSheet(sender)
        })
        actionSheet.addAction(cancel)
        return actionSheet
    }
    
    /// Returns action sheet to be presented in response to filter menu option selected.
    /// - returns: A UIAlertController to be presented as an action sheet.
    private func filterByTypeAlertController(_ sender: UIBarButtonItem) -> UIAlertController {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        viewModel.filtersByType().forEach { filter in
            let filterOption = UIAlertAction(title: filter.name, style: .default) { _ in
                self.dismiss(animated: true, completion: nil)
                self.viewModel.applyFilter(filter)
                self.tableView.reloadData()
            }
            actionSheet.addAction(filterOption)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            self.dismiss(animated: true, completion: nil)
            self.presentActionSheet(sender)
        })
        actionSheet.addAction(cancel)
        return actionSheet
    }
    
    /// Determines whether or not this view controller should dismiss itself
    /// or whether code outside the controller is responsible for this.
    private func viewControllerShouldDismiss() -> Bool {
        return navigationSettings?.autoClose ?? true // default to auto-close
    }
    
    /// Hides or unhides the navigation bar according to navigational preferences.
    private func hideNavigationBarIfNeeded() {
        let isNavigationBarHidden: Bool? = navigationSettings?.isNavigationBarHidden
        if let isNavigationBarHidden = isNavigationBarHidden {
            navigationController?.isNavigationBarHidden = isNavigationBarHidden
        }
    }
    
    /// Retrieves the current bundle
    private func currentBundle() -> Bundle {
        return Bundle(for: type(of: self))
    }
    
    private func presentPickerViewController(on viewController: UIViewController, with feature: Feature) {
        let viewControllerIdentifer = "TestVariationPickerViewController"
        let storyboard = UIStoryboard(name: "PickerViewController", bundle: currentBundle())
        guard let pickerViewController = storyboard.instantiateViewController(withIdentifier:
            viewControllerIdentifer) as? TestVariationPickerViewController else { return }
        let defaultValue: Test.Variation = feature.testVariation()
        let selectedTestVariation = feature.testVariations.firstIndex(where: { $0 == defaultValue }) ?? 0
        if let pickerOptionsViewModel = PickerOptionsViewModel<Test.Variation>(options:
            feature.testVariations, selectedOption: selectedTestVariation) {
            pickerViewController.viewModel = ["Test Variation": pickerOptionsViewModel]
            pickerViewController.modalPresentationStyle = .overFullScreen
            pickerViewController.selection = { [weak self] selectedVariation in
                FeatureFlags.updateFeatureTestVariation(feature: feature.name, testVariation: selectedVariation)
                self?.tableView.reloadData()
            }
            viewController.present(pickerViewController, animated: false, completion: nil)
        }
    }
    
}
#endif
