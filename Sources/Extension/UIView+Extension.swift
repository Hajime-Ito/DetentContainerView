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
        if let contentView = contentViewController.view {
            addSubview(contentView)
            contentView.translatesAutoresizingMaskIntoConstraints = false
            contentView.topAnchor.constraint(lessThanOrEqualTo: topAnchor, constant: topPadding).isActive = true
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            bringSubviewToFront(contentView)
        }
        contentViewController.didMove(toParent: parentViewController)
    }

    func add(contentView: UIView, topPadding: CGFloat) {
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(lessThanOrEqualTo: topAnchor, constant: topPadding).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        bringSubviewToFront(contentView)
    }
}
