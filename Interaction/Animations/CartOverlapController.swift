import UIKit

final class CartOverlapController: UIPresentationController {
    private var dimmingView: UIView

    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        dimmingView = UIView()
        dimmingView.backgroundColor = UIColor(white: 0, alpha: 0.4)
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }

    override func presentationTransitionWillBegin() {
        guard let container = containerView else {
            fatalError()
        }

        dimmingView.frame = container.bounds
        container.addSubview(dimmingView)

        dimmingView.addSubview(presentedViewController.view)
        dimmingView.alpha = 0

        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { context in
            self.dimmingView.alpha = 1
        }, completion: nil)
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            dimmingView.removeFromSuperview()
        }
    }

    override func dismissalTransitionWillBegin() {
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { context in
            self.dimmingView.alpha = 0
        }, completion: nil)
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            dimmingView.removeFromSuperview()
        }
    }

    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)

        if let presentedView = presentedView {
            presentedView.frame = self.frameOfPresentedViewInContainerView;
        }
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else {
            return super.frameOfPresentedViewInContainerView
        }

        let newOriginY = containerView.bounds.height - presentedViewController.preferredContentSize.height

        return CGRect(origin: CGPoint(x: 0, y: newOriginY), size: presentedViewController.preferredContentSize)
    }
}
