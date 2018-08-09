import UIKit

final class ViewController: UIViewController {

    @IBOutlet var cartView: UIView!
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!

    var router: CartViewRouter!

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

final class CartAnimator: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning {
    let externalPanGestureRecognizer: UIPanGestureRecognizer
    weak var router: CartViewRouter!
    var panGestureRecognizer: UIPanGestureRecognizer?

    init(panGestureRecognizer: UIPanGestureRecognizer) {
        self.externalPanGestureRecognizer = panGestureRecognizer
        super.init()

        panGestureRecognizer.addTarget(self, action: #selector(trackPanGesture(using:)))
    }

    var appearance = true 
    var isInteractive = false

    func createInterruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewPropertyAnimator {

        if appearance {
            let toView = transitionContext.view(forKey: .to)!

            let containerView = transitionContext.containerView
            containerView.addSubview(toView)

            let fromVC = transitionContext.viewController(forKey: .from) as! ViewController

            toView.translatesAutoresizingMaskIntoConstraints = false
            let bottom = toView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            let leading = toView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor)
            let trailing = toView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
            let heightConstraint = toView.heightAnchor.constraint(equalToConstant: fromVC.cartView.bounds.height)

            NSLayoutConstraint.activate([
                bottom,
                leading,
                trailing,
                heightConstraint
                ])

            containerView.layoutIfNeeded()

            let toFrame = fromVC.view.bounds.divided(atDistance: 300, from: .minYEdge).remainder

            let animator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext), curve: .easeIn) {
                heightConstraint.constant = toFrame.height
                containerView.layoutIfNeeded()
            }

            animator.addCompletion { position in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }

            let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(trackPanGesture(using:)))
            toView.addGestureRecognizer(gestureRecognizer)

            return animator
        } else {
            let fromView = transitionContext.view(forKey: .from)!
            let fromVC = transitionContext.viewController(forKey: .to) as! ViewController
            let containerView = transitionContext.containerView

            guard let heightConstraint = fromView.findConstraint(with: .height) else {
                fatalError()
            }
            let initialHeight = heightConstraint.constant

            let animator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext), curve: .easeIn) {
                heightConstraint.constant = fromVC.cartView.frame.height
                containerView.layoutIfNeeded()
            }

            animator.addCompletion { position in
                let completed = !transitionContext.transitionWasCancelled
                print("completed: \(completed)")
                if !completed {
                    heightConstraint.constant = initialHeight
                }

                transitionContext.completeTransition(completed)
            }

            return animator
        }
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
        let view = recognizer.view!

        if recognizer === externalPanGestureRecognizer {
            let translation = recognizer.translation(in: view)
            let verticalMovement = abs(translation.y / 300)
            let progress: CGFloat = min(verticalMovement, 1)

            switch recognizer.state {
            case .began:
                isInteractive = true
                router.showCart()
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
        } else {
            let translation = recognizer.translation(in: view)
            let verticalMovement = translation.y / 300
            let progress: CGFloat = max(verticalMovement, 0)

            switch recognizer.state {
            case .began:
                isInteractive = true
                router.closeCart()
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
}

extension UIView {
    func findConstraint(with attribute: NSLayoutAttribute) -> NSLayoutConstraint? {
        for constraint in constraints {
            if constraint.firstItem === self && constraint.firstAttribute == attribute {
                return constraint
            } else if constraint.secondItem === self && constraint.secondAttribute == attribute {
                return constraint
            }
        }

        return nil
    }
}
