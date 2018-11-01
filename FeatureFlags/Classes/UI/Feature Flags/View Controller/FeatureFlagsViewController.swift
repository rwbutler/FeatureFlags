//
//  FeatureFlagsViewController.swift
//  FeatureFlags
//
//  Created by Ross Butler on 10/19/18.
//

import Foundation
import UIKit

class FeatureFlagsViewController: UITableViewController {
    
    // MARK: Type definitions
    public typealias Delegate = FeatureFlagsViewControllerDelegate
    public typealias NavigationSettings = FeatureFlagsViewControllerNavigationSettings
    
    // MARK: State
    var delegate: Delegate?
    var navigationSettings: NavigationSettings?
    
    override init(style: UITableView.Style) {
        super.init(style: style)
        FeatureFlags.refresh()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        FeatureFlags.refresh()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Feature Flags"
        configureView()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRows = FeatureFlags.configuration?.count ?? 0
        return numberOfRows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let green = UIColor(red: 151.0/255.0, green: 201.0/255.0, blue: 61.0/255.0, alpha: 1.0)
        let cellReuseIdentifier = String(describing: FeatureFlagTableViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        guard let featureFlagCell = cell as? FeatureFlagTableViewCell,
            var features = FeatureFlags.configuration,
            indexPath.row < features.count else {
                return cell
        }
        features = sortedFeatures(features)
        let feature = features[indexPath.row]
        let testVariation = feature.testVariation()
        featureFlagCell.featureName.text = feature.name.rawValue
        featureFlagCell.featureEnabled.isOn = feature.isEnabled()
        featureFlagCell.featureType.text = feature.type.description
        featureFlagCell.testVariation.text = testVariation.description
        featureFlagCell.featureEnabled.onTintColor = green
        switch  feature.type {
        case .featureFlag:
            featureFlagCell.featureEnabled.isHidden = false
            featureFlagCell.testVariation.isHidden = false
        default:
            featureFlagCell.featureEnabled.isHidden = true
            featureFlagCell.testVariation.isHidden = false
        }
        
        let allLabels = [featureFlagCell.featureName, featureFlagCell.featureType, featureFlagCell.testVariation]
        
        switch feature.type {
        case .featureFlag, .featureTest(.featureFlagAB):
            allLabels.forEach({ label in
                label?.textColor = UIColor.white
            })
            cell.contentView.backgroundColor = feature.isEnabled()
                ? UIColor(red: 63.0/255.0, green: 134.0/255.0, blue: 80.0/255.0, alpha: 1.0)
                : UIColor(red: 189.0/255.0, green: 50.0/255.0, blue: 80.0/255.0, alpha: 1.0)
        case .featureTest(.ab), .featureTest(.mvt), .deprecated:
            allLabels.forEach({ label in
                label?.textColor = UIColor.black
            })
            cell.contentView.backgroundColor = UIColor.white
        }
        featureFlagCell.featureEnabled.isHidden = true // Always hide for now
        return featureFlagCell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard var features = FeatureFlags.configuration, indexPath.row < features.count else {
                return
            }
            features = sortedFeatures(features)
            let feature = features[indexPath.row]
            FeatureFlags.deleteFeatureFromCache(named: feature.name)
            let refreshedFeatures = FeatureFlags.refresh() ?? []
            if refreshedFeatures.count != features.count {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    private func sortedFeatures(_ features: [Feature]) -> [Feature] {
        var mutableFeatures = features
        mutableFeatures.sort(by: { (lhs, rhs) -> Bool in
            return lhs.name.rawValue < rhs.name.rawValue
        })
        return mutableFeatures
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
        guard var features = FeatureFlags.configuration, indexPath.row < features.count else {
            return
        }
        features = sortedFeatures(features)
        let feature = features[indexPath.row]
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
        case .deprecated:
            break
        }
    }
}

private extension FeatureFlagsViewController {
    private func configureNavigationBar() {
        let closeButtonType = navigationSettings?.closeButton ?? .done
        let doneButton = UIBarButtonItem(barButtonSystemItem: closeButtonType, target: self, action: #selector(close))
        let closeButtonAlignment = navigationSettings?.closeButtonAlignment ?? .left
        switch closeButtonAlignment {
        case .left:
            navigationItem.leftBarButtonItem = doneButton
        case .right:
            navigationItem.rightBarButtonItem = doneButton
        }
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
        if navigationSettings?.autoClose ?? true {
            if let navigationController = navigationController, let settings = navigationSettings {
                navigationController.isNavigationBarHidden = settings.isNavigationBarHidden
                navigationController.popViewController(animated: settings.animated)
            } else {
                dismiss(animated: navigationSettings?.animated ?? false, completion: nil)
            }
        }
        delegate?.viewControllerDidFinish()
    }
    
    /// Retrieves the current bundle
    private func currentBundle() -> Bundle {
        return Bundle(for: type(of: self))
    }
    
    private func presentPickerViewController(on viewController: UIViewController, with feature: Feature) {
        let storyboard = UIStoryboard(name: "PickerViewController", bundle: currentBundle())
        if let pickerViewController = storyboard.instantiateViewController(withIdentifier: "TestVariationPickerViewController") as? TestVariationPickerViewController {
            let defaultValue: Test.Variation = feature.testVariation()
            let selectedTestVariation = feature.testVariations.index(where: { $0 == defaultValue }) ?? 0
            if let pickerOptionsViewModel = PickerOptionsViewModel<Test.Variation>(options: feature.testVariations, selectedOption: selectedTestVariation) {
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
    
    func detailViewController(for index: Int) -> FeatureDetailsViewController {
        let viewController = FeatureDetailsViewController(style: .grouped)
        if var features = FeatureFlags.configuration {
            features = sortedFeatures(features)
            viewController.feature = features[index]
        }
        return viewController
    }
}

extension FeatureFlagsViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = tableView.indexPathForRow(at: location) {
            previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
            return detailViewController(for: indexPath.row)
        }
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
    
}
