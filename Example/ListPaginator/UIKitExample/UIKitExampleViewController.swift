import Foundation
import UIKit
import ListPaginator

final class UIKitExampleViewController: UIViewController, ExampleViewController {
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var retryButton: UIButton!

    let paginator = ListPaginator<PassengersResponse, Passenger>(strategy: .pageIndex(startingFrom: 1), responseItemsKeyPath: \.passengers)

    override func viewDidLoad() {
        super.viewDidLoad()

        retryButton.isHidden = true

        paginator.requestProvider = .closure({ page, completion in
            PassengersRequest(page: page).performRequest(completion: completion)
        })
        paginator.completionHandler = { _ in
            self.retryButton.isHidden = self.paginator.status.error == nil
            self.tableView.reloadData()
        }

        paginator.fetchMoreIfNeeded.send()
    }

    @IBAction private func didTapRetry() {
        paginator.fetchMoreIfNeeded.send()
    }

    func clearAll() {
        paginator.reset()
        paginator.fetchMoreIfNeeded.send()
    }
}

extension UIKitExampleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        paginator.results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? UIKitExampleTableViewCell else {
            return UITableViewCell()
        }

        cell.titleLabel.text = paginator.results[indexPath.row].name
        return cell
    }
}

extension UIKitExampleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == paginator.results.count - 3, paginator.status.error == nil {
            paginator.fetchMoreIfNeeded.send()
        }
    }
}

final class UIKitExampleTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
}
