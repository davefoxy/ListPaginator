import UIKit
import SwiftUI

class SwiftUIExampleViewController: UIViewController, ExampleViewController {
    private let exampleView = SwiftUIExampleView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hostingController = UIHostingController(rootView: exampleView)
        addChildViewController(hostingController)
        hostingController.didMove(toParentViewController: self)
        view.addSubview(hostingController.view)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        exampleView.paginator.fetchMoreIfNeeded.send()
    }
    
    func clearAll() {
        exampleView.paginator.reset()
        exampleView.paginator.fetchMoreIfNeeded.send()
    }
}

