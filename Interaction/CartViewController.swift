import UIKit

final class CartViewController: UIViewController {

    @IBOutlet var totalLabel: UILabel!
    @IBOutlet var itemsLabel: UILabel!
    @IBOutlet var headerView: UIView!
    @IBOutlet var cartBottomView: UIView!
    @IBOutlet var tableView: UITableView!

    @IBOutlet var leadingItemsLabelConstraint: NSLayoutConstraint!
    @IBOutlet var topItemsLabelConstraint: NSLayoutConstraint!
    @IBOutlet var leadingPriceLabelConstraint: NSLayoutConstraint!

    private var initialLeadingValue: CGFloat = 0
    private var initialTopValue: CGFloat = 0
    private var dataSource = ["a strong wish, especially one that is difficult or impossible to control", "a strong desire or need", "to encourage someone strongly to do something or to ask that something be done",]
    private var cellHeightCache = Array(repeating: CGFloat(80), count: 3)

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "CartCell", bundle: nil), forCellReuseIdentifier: "CartCell")

        let height = headerView.bounds.height * 2 + cellHeightCache.reduce(0, +)
        preferredContentSize = CGSize(width: view.bounds.width, height: height)
    }

    @IBAction func closeCart() {
        dismiss(animated: true, completion: nil)
    }

    func prepareForAnimation() {
        totalLabel.alpha = 0

        initialLeadingValue = leadingPriceLabelConstraint.constant
        initialTopValue = totalLabel.convert(totalLabel.frame, to: cartBottomView).minY

        leadingItemsLabelConstraint.constant = initialLeadingValue
        topItemsLabelConstraint.constant = initialTopValue
    }

    func adjustState(with fraction: CGFloat) {
        totalLabel.alpha = fraction

        let headerViewBounds = headerView.bounds
        let itemsLabelBounds = itemsLabel.bounds

        leadingItemsLabelConstraint.constant = ((headerViewBounds.width - itemsLabelBounds.width) / 2 - initialLeadingValue)  * fraction + initialLeadingValue
        topItemsLabelConstraint.constant = ((headerViewBounds.height - itemsLabelBounds.height) / 2 - initialTopValue) * fraction + initialTopValue
    }
}

extension CartViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartCell") as! CartCell

        cell.descriptionLabel.text = dataSource[indexPath.row]

        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let previousValue = cellHeightCache[indexPath.row]
        cellHeightCache[indexPath.row] = cell.bounds.height

        if previousValue != cell.bounds.height {
            let height = headerView.bounds.height * 2 + cellHeightCache.reduce(0, +)
            preferredContentSize = CGSize(width: view.bounds.width, height: height)
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeightCache[indexPath.row]
    }
}

