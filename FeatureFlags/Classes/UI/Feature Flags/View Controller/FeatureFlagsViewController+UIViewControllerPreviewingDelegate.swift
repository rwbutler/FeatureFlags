//
//  FeatureFlagsViewController+UIViewControllerPreviewing.swift
//  FeatureFlags
//
//  Created by Ross Butler on 23/12/2019.
//

import Foundation

extension FeatureFlagsViewController: UIViewControllerPreviewingDelegate {
    
    private func detailViewController(for indexPath: IndexPath) -> FeatureDetailsViewController {
        let viewController = FeatureDetailsViewController(style: .grouped)
        viewController.feature = viewModel.feature(for: indexPath)
        return viewController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                           viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = tableView.indexPathForRow(at: location) {
            previewingContext.sourceRect = tableView.rectForRow(at: indexPath)
            return detailViewController(for: indexPath)
        }
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                           commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
    
}
