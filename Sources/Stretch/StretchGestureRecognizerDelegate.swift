import UIKit

final class StretchGestureRecognizerDelegate: NSObject, UIGestureRecognizerDelegate {

    var canScrollContent = false

    private var recognizedScrollView: UIScrollView?
    private var _didPanScrollViewOnContentView: (UIPanGestureRecognizer) -> Void

    private weak var containerViewGestureRecognizer: UIPanGestureRecognizer?

    init(
        containerViewGestureRecognizer: UIPanGestureRecognizer?,
        didPanScrollViewOnContentView: @escaping (UIPanGestureRecognizer) -> Void
    )
    {
        self.containerViewGestureRecognizer = containerViewGestureRecognizer
        self._didPanScrollViewOnContentView = didPanScrollViewOnContentView
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool
    {
        if let scrollView = otherGestureRecognizer.view as? UIScrollView {
            configure(scrollView: scrollView)
        }

        if gestureRecognizer === containerViewGestureRecognizer, !canScrollContent {
            return true
        }

        return false
    }

}

extension StretchGestureRecognizerDelegate {
    
    private func configure(scrollView: UIScrollView) {
        guard recognizedScrollView !== scrollView else { return }
        recognizedScrollView = scrollView
        recognizedScrollView?.contentInsetAdjustmentBehavior = .never
        recognizedScrollView?.panGestureRecognizer.addTarget(
            self,
            action: #selector(didPanScrollViewOnContainerView(_:))
        )
    }

    @objc
    private func didPanScrollViewOnContainerView(_ gestureRecognizer: UIPanGestureRecognizer) {
        _didPanScrollViewOnContentView(gestureRecognizer)
    }

}
