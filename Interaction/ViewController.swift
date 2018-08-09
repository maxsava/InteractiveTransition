import UIKit

final class ViewController: UIViewController {

    @IBOutlet var cartView: UIView!
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!

    private var router: CartViewRouter!

    override func viewDidLoad() {
        super.viewDidLoad()

        let animator = CartAnimator(panGestureRecognizer: panGestureRecognizer)
        let transitioner = CartTransitioner(animator: animator)

        router = CartViewRouter(sourceViewController: self, transitioner: transitioner)
        animator.router = router
    }

    @IBAction func showCart() {
        router.showCart()
    }
}
