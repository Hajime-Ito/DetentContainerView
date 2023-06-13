import UIKit

final class StretchGestureHandler {

    var stretch: Optional<((translation: CGPoint, velocity: CGPoint)) -> Void> = nil
    var finishStretch: Optional<((translation: CGPoint, velocity: CGPoint)) -> Void> = nil
    var canScrollContent: Bool = false

    private var isStretchedByContentScrollView = false

    private lazy var stretchGestureRecognizerDelegate = StretchGestureRecognizerDelegate(
        containerViewGestureRecognizer: containerViewGestureRecognizer,
        didPanScrollViewOnContentView: { [weak self] recognizer in self?.didPanScrollViewOnContentView(recognizer) }
    )

    private lazy var containerViewGestureRecognizer = UIPanGestureRecognizer(
        target: self,
        action: #selector(didPanContainerView(_:))
    )

    private weak var containerView: UIView?

    init(containerView: UIView?) {
        self.containerView = containerView
        containerViewGestureRecognizer.delegate = stretchGestureRecognizerDelegate
        self.containerView?.addGestureRecognizer(containerViewGestureRecognizer)
    }

    func reset(canScrollContent: Bool) {
        self.canScrollContent = canScrollContent
        stretchGestureRecognizerDelegate.canScrollContent = canScrollContent
    }

}

extension StretchGestureHandler {

    @objc
    private func didPanContainerView(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            stretchGestureRecognizerDelegate.canScrollContent = false

        case .changed:
            let translation = gestureRecognizer.translation(in: containerView)
            let velocity = gestureRecognizer.velocity(in: containerView)
            stretch?((translation: translation, velocity: velocity))
            gestureRecognizer.setTranslation(.zero, in: containerView)

        case .ended:
            let translation = gestureRecognizer.translation(in: containerView)
            let velocity = gestureRecognizer.velocity(in: containerView)
            finishStretch?((translation: translation, velocity: velocity))
            stretchGestureRecognizerDelegate.canScrollContent = canScrollContent

        default:
            break
        }
    }

    @objc
    private func didPanScrollViewOnContentView(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            containerView?.parentViewController?.isModalInPresentation = true

        case .changed:
            guard let scrollView = gestureRecognizer.view as? UIScrollView else { return }

            if scrollView.contentOffset.y <= 0,
                gestureRecognizer.translation(in: containerView).y > 0,
                !isStretchedByContentScrollView {
                isStretchedByContentScrollView = true
                stretchGestureRecognizerDelegate.canScrollContent = false
                gestureRecognizer.setTranslation(.zero, in: containerView)
            }

            if isStretchedByContentScrollView {
                scrollView.contentOffset.y = .zero
                let translation = gestureRecognizer.translation(in: containerView)
                let velocity = gestureRecognizer.velocity(in: containerView)
                stretch?((translation: translation, velocity: velocity))
                gestureRecognizer.setTranslation(.zero, in: containerView)
            }

        case .ended:
            guard let scrollView = gestureRecognizer.view as? UIScrollView else { return }
            containerView?.parentViewController?.isModalInPresentation = false
            if isStretchedByContentScrollView {
                scrollView.bounces = false
                let translation = gestureRecognizer.translation(in: containerView)
                let velocity = gestureRecognizer.velocity(in: containerView)
                finishStretch?((translation: translation, velocity: velocity))
                isStretchedByContentScrollView = false
                stretchGestureRecognizerDelegate.canScrollContent = canScrollContent
            } else {
                scrollView.bounces = true
            }

        default:
            break
        }
    }

}
