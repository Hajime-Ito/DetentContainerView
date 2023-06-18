//
//  RotatableView.swift
//  EmbededSemiModal
//
//  Created by Hajime Ito on 2023/02/01.
//

import Foundation
import UIKit

public class RotatableView: UIView {

    public struct LandscapeConfiguration {
        public enum XPosition {
            case center
            case leading
            case trailing
        }

        public var position: XPosition
        public var width: CGFloat

        public init(position: XPosition, width: CGFloat) {
            self.position = position
            self.width = width
        }
    }

    final var landscapeConfiguration = LandscapeConfiguration(position: .trailing, width: 340)

    var _marginFromSideEdge: CGFloat {
        0.0
    }

    private var orientation: UIDeviceOrientation?
    private var widthConstraint: NSLayoutConstraint?
    private var leadingToSuperViewConstraint: NSLayoutConstraint?
    private var trailingToSuperViewConstraint: NSLayoutConstraint?
    private var centerXToSuperViewConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        translatesAutoresizingMaskIntoConstraints = false
    }

    public override func updateConstraints() {
        if let superview = superview {
            initializeConstraintsIfNeeded(superview: superview)
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateOrientation(_:)),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )

        super.updateConstraints()
    }

    func viewDidRotated(currentOrientation: UIDeviceOrientation, previousOrientation: UIDeviceOrientation?) {
        switch currentOrientation {
        case .portrait:
            viewDidRotatedToPortrait(previousOrientation: previousOrientation)

        case .landscapeLeft, .landscapeRight:
            viewDidRotatedToLandscape(previousOrientation: previousOrientation)

        default:
            break
        }
    }
    
}

extension RotatableView {

    @objc
    private func updateOrientation(_ notification: NSNotification) {
        switch UIDevice.current.orientation {
        case .portrait:
            guard orientation != .portrait else { return }
            let previous = orientation
            orientation = .portrait
            viewDidRotated(currentOrientation: .portrait, previousOrientation: previous)

        case .landscapeLeft, .landscapeRight:
            guard orientation != .landscapeLeft else { return }
            guard orientation != .landscapeRight else { return }
            let previous = orientation
            orientation = UIDevice.current.orientation
            viewDidRotated(currentOrientation: UIDevice.current.orientation, previousOrientation: previous)

        default:
            if orientation == nil {
                orientation = .portrait
                viewDidRotated(currentOrientation: .portrait, previousOrientation: nil)
            }
        }
    }

    private func setMarginFromSideEdge() {
        if orientation?.isLandscape == true {
            switch landscapeConfiguration.position {
            case .trailing:
                let safeArea = window?.safeAreaInsets.right ?? 0
                trailingToSuperViewConstraint?.constant = -(_marginFromSideEdge + safeArea)
            case .leading:
                let safeArea = window?.safeAreaInsets.left ?? 0
                leadingToSuperViewConstraint?.constant = _marginFromSideEdge + safeArea
            case .center:
                break
            }
        } else {
            trailingToSuperViewConstraint?.constant = -_marginFromSideEdge
            leadingToSuperViewConstraint?.constant = _marginFromSideEdge
        }
    }

    private func initializeConstraintsIfNeeded(superview: UIView) {
        guard widthConstraint == nil, leadingToSuperViewConstraint == nil, trailingToSuperViewConstraint == nil else {
            return
        }

        let layoutGuideLeading = superview.safeAreaLayoutGuide.leadingAnchor
        let layoutGuideTrailing = superview.safeAreaLayoutGuide.trailingAnchor

        widthConstraint = widthAnchor.constraint(equalToConstant: landscapeConfiguration.width)
        leadingToSuperViewConstraint = leadingAnchor.constraint(equalTo: layoutGuideLeading, constant: _marginFromSideEdge)
        trailingToSuperViewConstraint = trailingAnchor.constraint(equalTo: layoutGuideTrailing, constant: -_marginFromSideEdge)
        centerXToSuperViewConstraint = centerXAnchor.constraint(equalTo: superview.centerXAnchor)

        widthConstraint?.isActive = false
        trailingToSuperViewConstraint?.isActive = true
        leadingToSuperViewConstraint?.isActive = true
        centerXToSuperViewConstraint?.isActive = false

        setMarginFromSideEdge()
    }

    private func viewDidRotatedToLandscape(previousOrientation: UIDeviceOrientation?) {
        switch landscapeConfiguration.position {
        case .trailing:
            trailingToSuperViewConstraint?.isActive = true
            leadingToSuperViewConstraint?.isActive = false
            centerXToSuperViewConstraint?.isActive = false

        case .leading:
            leadingToSuperViewConstraint?.isActive = true
            trailingToSuperViewConstraint?.isActive = false
            centerXToSuperViewConstraint?.isActive = false

        case .center:
            trailingToSuperViewConstraint?.isActive = false
            leadingToSuperViewConstraint?.isActive = false
            centerXToSuperViewConstraint?.isActive = true
        }
        widthConstraint?.isActive = true
        widthConstraint?.constant = landscapeConfiguration.width
    }

    private func viewDidRotatedToPortrait(previousOrientation: UIDeviceOrientation?) {
        widthConstraint?.isActive = false
        trailingToSuperViewConstraint?.isActive = true
        leadingToSuperViewConstraint?.isActive = true
    }
}
