import Foundation
import UIKit

final class DebugViewController: UIViewController {
    @IBAction private func didTapClearAll() {
        tabBarController?
            .viewControllers?
            .forEach { viewController in
                (viewController as? ExampleViewController)?.clearAll()
            }
    }

    @IBAction private func didTapSimulateError() {
        simulateAPIError = true
    }
}
