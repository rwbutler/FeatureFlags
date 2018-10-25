//
//  FeatureDetailsViewController.swift
//  FeatureFlags
//
//  Created by Ross Butler on 10/23/18.
//

import Foundation
import UIKit

class FeatureDetailsViewController: UITableViewController {
    
    // MARK: Type definitions
    public struct NavigationSettings {
        let animated: Bool
        let isNavigationBarHidden: Bool
    }
    
    // MARK: State
    var feature: Feature?
    var navigationSettings: NavigationSettings?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let feature = self.feature else { return }
        title = feature.name.description
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let feature = self.feature else { return 0 }
        switch feature.type {
        case .deprecated:
            return 0
        case .featureFlag:
            return 3
        case .featureTest(.featureFlagAB), .featureTest(.ab), .featureTest(.mvt):
            return 5
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellReuseIdentifier = "\(String(describing: self))Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellReuseIdentifier)
        guard let feature = self.feature else {
            return cell
        }
        cell.textLabel?.font = UIFont(name: "Avenir-Light", size: 16.0)
        cell.detailTextLabel?.font = UIFont(name: "Avenir-Medium", size: 20.0)
        cell.detailTextLabel?.numberOfLines = 0
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Feature type"
            cell.detailTextLabel?.text = feature.type.description
        case 1:
            let enabled = feature.isEnabled()
            cell.textLabel?.text = ""
            cell.detailTextLabel?.text = enabled ? "Enabled" : "Disabled"
        case 2:
            switch feature.type {
            case .featureFlag, .deprecated:
                cell.textLabel?.text = "Labels"
                let labels = feature.labels.compactMap({ $0 })
                if !labels.isEmpty {
                    cell.detailTextLabel?.text = labels.joined(separator: ", ")
                } else {
                    cell.detailTextLabel?.text = "None"
                }
            case .featureTest(.featureFlagAB), .featureTest(.ab), .featureTest(.mvt):
                cell.textLabel?.text = "Test variations"
                if let feature = self.feature {
                    let variationsStr = zip(feature.testVariations, feature.testBiases).map{ testVariation, testBias in
                        return "\(testVariation) (\(testBias))"
                        }.joined(separator: ", ")
                    cell.detailTextLabel?.text = variationsStr
                } else {
                    cell.detailTextLabel?.text = ""
                }
            }
        case 3:
            
            cell.textLabel?.text = "Test variation assignment"
            if let feature = self.feature {
                let testVariationAssignment = String(format: "%.f", feature.testVariationAssignment)
                let assignmentStr = "\(testVariationAssignment)% -> \(feature.testVariation())"
                cell.detailTextLabel?.text = assignmentStr
            } else {
                cell.detailTextLabel?.text = ""
            }
            
        case 4:
            cell.textLabel?.text = "Labels"
            let labels = feature.labels.compactMap({ $0 })
            if !labels.isEmpty {
                cell.detailTextLabel?.text = labels.joined(separator: ", ")
            } else {
                cell.detailTextLabel?.text = "None"
            }
        default:
            break
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

private extension FeatureDetailsViewController {
    private func configureNavigationBar() {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close))
        navigationItem.leftBarButtonItem = doneButton
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    func configureView() {
        configureNavigationBar()
        configureTableView()
    }
    
    @objc func close() {
        if let navigationController = navigationController, let settings = navigationSettings {
            navigationController.isNavigationBarHidden = settings.isNavigationBarHidden
            navigationController.popViewController(animated: settings.animated)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}

