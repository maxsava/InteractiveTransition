import UIKit

final class CartTransitioner: NSObject, UIViewControllerTransitioningDelegate {
    private let animator: CartAnimator

    init(animator: CartAnimator) {
        self.animator = animator
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.isAppearance = true
        return animator
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.isAppearance = false
        return animator
    }

    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.animator.isInteractive ? self.animator : nil
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.animator.isInteractive ? self.animator : nil
    }

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CartOverlapController(presentedViewController: presented, presenting: presenting)
    }
}
