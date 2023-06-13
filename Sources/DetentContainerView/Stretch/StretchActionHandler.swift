import UIKit

class StretchActionHandler {

    struct StretchViewConfiguration {
        let initialHeight: CGFloat
        let minimumHeight: CGFloat
        let maximumHeight: CGFloat
        let initialMarginFromBottom: CGFloat
    }

    var height: CGFloat {
        get { heightConstraint?.constant ?? 0 }
        set { heightConstraint?.constant = newValue }
    }

    var marginFromBottom: CGFloat {
        get { bottomConstraint?.constant ?? 0 }
        set { bottomConstraint?.constant = newValue }
    }

    var stretchViewConfiguration: StretchViewConfiguration
    
    private(set) weak var view: UIView?

    private lazy var heightConstraint = {
        guard let view = view else { return Optional<NSLayoutConstraint>.none }
        let constraint = view.heightAnchor.constraint(equalToConstant: view.frame.size.height)
        return constraint
    }()
    
    private lazy var bottomConstraint = {
        guard let view = view, let superview = view.superview else { return Optional<NSLayoutConstraint>.none }
        let constraint = superview.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        return constraint
    }()

    init(
        stretchView: UIView?,
        stretchViewConfiguration: StretchViewConfiguration
    ) {
        self.view = stretchView
        self.stretchViewConfiguration = stretchViewConfiguration
        heightConstraint?.isActive = true
        heightConstraint?.constant = stretchViewConfiguration.initialHeight
        bottomConstraint?.isActive = true
        bottomConstraint?.constant = stretchViewConfiguration.initialMarginFromBottom
    }

    func set(stretchViewConfiguration: StretchViewConfiguration) {
        self.stretchViewConfiguration = stretchViewConfiguration
        heightConstraint?.constant = stretchViewConfiguration.initialHeight
        bottomConstraint?.constant = stretchViewConfiguration.initialMarginFromBottom
    }

}

extension StretchActionHandler {

    func stretch(to height: CGFloat, animations: (() -> Void)?, completion: (() -> Void)?) {
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.65,
            initialSpringVelocity: 1.5,
            options: [.curveEaseOut],
            animations: {
                self.heightConstraint?.constant = height
                animations?()
                self.view?.superview?.layoutIfNeeded()
            },
            completion: { _ in
                completion?()
            }
        )
    }

    func appear(height: CGFloat, animations: (() -> Void)?, completion: (() -> Void)?) {
        view?.isHidden = false
        UIView.animate(
            withDuration: 0.45,
            delay: 0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 1.5,
            options: [.curveEaseOut],
            animations: {
                self.bottomConstraint?.constant = self.stretchViewConfiguration.initialMarginFromBottom
            },
            completion: { _ in
                self.stretch(to: height, animations: animations, completion: completion)
            }
        )
    }

    func appear(animations: (() -> Void)?, completion: (() -> Void)?) {
        view?.isHidden = false
        UIView.animate(
            withDuration: 0.45,
            delay: 0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 1.5,
            options: [.curveEaseOut],
            animations: {
                self.bottomConstraint?.constant = self.stretchViewConfiguration.initialMarginFromBottom
                animations?()
                self.view?.superview?.layoutIfNeeded()
            },
            completion: { _ in
                completion?()
            }
        )
    }

    func disappear(animations: (() -> Void)?, completion: (() -> Void)?) {
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: [.curveEaseOut],
            animations: {
                if let stretchViewHeight = self.heightConstraint?.constant {
                    self.bottomConstraint?.constant = -(stretchViewHeight + 50)
                }
                animations?()
                self.view?.superview?.layoutIfNeeded()
            },
            completion: { _ in
                completion?()
                self.view?.isHidden = true
            }
        )
    }

}
