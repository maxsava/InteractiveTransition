import UIKit

final class CartAnimator: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning {

    let externalPanGestureRecognizer: UIPanGestureRecognizer
    weak var router: CartViewRouter!

    var isAppearance = true
    var isInteractive = false

    private var cartViewController: CartViewController!

    init(panGestureRecognizer: UIPanGestureRecognizer) {
        externalPanGestureRecognizer = panGestureRecognizer
        super.init()

        panGestureRecognizer.addTarget(self, action: #selector(trackPanGesture(using:)))
    }

    func createInterruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewPropertyAnimator {
        let cartViewController: CartViewController
        let cartView: UIView
        let toFrame: CGRect
        let fraction: CGFloat

        if isAppearance {
            cartViewController = transitionContext.viewController(forKey: .to) as! CartViewController
            cartView = transitionContext.view(forKey: .to)!

            let containerView = transitionContext.containerView
            containerView.addSubview(cartViewController.view)

            let containerViewController = transitionContext.viewController(forKey: .from) as! ViewController
            toFrame = containerView.bounds.divided(atDistance: cartViewController.preferredContentSize.height, from: .maxYEdge).slice

            cartViewController.prepareForAnimation()
            cartView.frame = containerViewController.cartView.frame
            containerView.layoutIfNeeded()

            let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(trackPanGesture(using:)))
            cartView.addGestureRecognizer(gestureRecognizer)
            fraction = 1
        } else {
            let containerViewController = transitionContext.viewController(forKey: .to) as! ViewController
            cartViewController = transitionContext.viewController(forKey: .from) as! CartViewController
            cartView = transitionContext.view(forKey: .from)!
            toFrame = containerViewController.cartView.frame
            fraction = 0
        }

        self.cartViewController = cartViewController

        let animator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext), curve: .easeIn) {
            cartView.frame = toFrame
            cartViewController.adjustState(with: fraction)
            cartView.layoutIfNeeded()
        }

        animator.addCompletion { position in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            if (transitionContext.transitionWasCancelled) {
                cartViewController.adjustState(with: 1 - fraction)
                cartView.setNeedsLayout()
            }
        }

        return animator
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        createInterruptibleAnimator(using: transitionContext).startAnimation()
    }

    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        return createInterruptibleAnimator(using: transitionContext)
    }

    @objc func trackPanGesture(using recognizer: UIPanGestureRecognizer) {
        guard let view = recognizer.view else {
            return
        }

        if case .began = recognizer.state {
            isInteractive = true
            if recognizer === externalPanGestureRecognizer {
                router.showCart()
            } else {
                router.closeCart()
            }

            return
        }

        let translation = recognizer.translation(in: view)
        let verticalMovement = translation.y / cartViewController.preferredContentSize.height
        let progress: CGFloat

        if recognizer === externalPanGestureRecognizer {
            progress = min(abs(min(verticalMovement, 0)), 1)
        } else {
            progress = max(verticalMovement, 0)
        }

        switch recognizer.state {
        case .changed:
            update(progress)
        case .ended, .cancelled, .failed:
            if progress > 0.5 {
                finish()
            } else {
                cancel()
            }
            isInteractive = false
        default:
            cancel()
            isInteractive = false
        }
    }
}
