import UIKit

final class CartViewRouter {
    weak var sourceViewController: UIViewController!
    let transitioner: CartTransitioner

    init(sourceViewController: UIViewController, transitioner: CartTransitioner) {
        self.sourceViewController = sourceViewController
        self.transitioner = transitioner
    }

    func showCart() {
        let cartViewController = CartViewController(nibName: "CartViewController", bundle: nil)

        cartViewController.modalPresentationStyle = .custom
        cartViewController.transitioningDelegate = transitioner

        sourceViewController.present(cartViewController, animated: true, completion: nil)
    }

    func closeCart() {
        sourceViewController.dismiss(animated: true, completion: nil)
    }
}
