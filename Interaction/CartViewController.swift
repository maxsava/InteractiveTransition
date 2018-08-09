import UIKit

final class CartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func closeCart() {
        dismiss(animated: true, completion: nil)
    }
}
