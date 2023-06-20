import UIKit

extension UIView {

    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while true {
            guard let nextResponder = parentResponder?.next else { return nil }
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            parentResponder = nextResponder
        }
    }

    func add(contentViewController: UIViewController, topPadding: CGFloat) {
        parentViewController?.addChild(contentViewController)
        addSubview(contentViewController.view)
        contentViewController.view.translatesAutoresizingMaskIntoConstraints = false
        contentViewController.view.topAnchor.constraint(equalTo: topAnchor, constant: topPadding).isActive = true
        contentViewController.view.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor).isActive = true
        contentViewController.view.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        contentViewController.view.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        bringSubviewToFront(contentViewController.view)
        contentViewController.didMove(toParent: parentViewController)
    }

    func add(contentView: UIView, topPadding: CGFloat) {
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: topAnchor, constant: topPadding).isActive = true
        contentView.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        bringSubviewToFront(contentView)
    }
}
