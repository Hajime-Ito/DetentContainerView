import UIKit

protocol StretchHandlerDelegate: NSObject {

    func stretchHandler(translation: CGPoint, velocity: CGPoint, didStretch viewHeight: CGFloat)
    func stretchHandler(translation: CGPoint, velocity: CGPoint, finishStretch viewHeight: CGFloat)
    func stretchHandlerDidDisappear()
    func stretchHandlerDidAppear()

}

final class StretchHandler {

    enum StretchSpeed: Float {
        case `default` = 0.8
        case slow = 0.05
        case zero = 0.0
    }
    
    weak var delegate: StretchHandlerDelegate?

    private let stretchGestureHandler: StretchGestureHandler
    private let stretchActionHandler: StretchActionHandler
    private let allowSlideDown: Bool

    private var canSlide = false

    init(
        stretchView: UIView,
        stretchViewConfiguration: StretchActionHandler.StretchViewConfiguration,
        allowSlideDown: Bool
    ) {
        self.allowSlideDown = allowSlideDown
        stretchActionHandler = StretchActionHandler(
            stretchView: stretchView,
            stretchViewConfiguration: stretchViewConfiguration
        )
        stretchGestureHandler = StretchGestureHandler(containerView: stretchView)
        setStretchGestureHandlerAction(stretchViewConfiguration: stretchViewConfiguration)
    }

    func set(stretchViewConfiguration: StretchActionHandler.StretchViewConfiguration) {
        stretchActionHandler.set(stretchViewConfiguration: stretchViewConfiguration)
        setStretchGestureHandlerAction(stretchViewConfiguration: stretchViewConfiguration)
    }

    func stretch(to height: CGFloat, animations: (() -> Void)?, completion: (() -> Void)?) {
        stretchActionHandler.stretch(to: height, animations: animations, completion: completion)
    }

    func appear(height: CGFloat, animations: (() -> Void)?, completion: (() -> Void)?) {
        stretchActionHandler.appear(height: height, animations: animations) { [weak self] in
            self?.delegate?.stretchHandlerDidAppear()
            completion?()
        }
    }

    func disappear(animations: (() -> Void)?, completion: (() -> Void)?) {
        stretchActionHandler.disappear(animations: animations) { [weak self] in
            self?.delegate?.stretchHandlerDidDisappear()
            completion?()
        }
    }

}

extension StretchHandler {

    private func handleSlide(translation: CGPoint, velocity: CGPoint) {

        let initialMarginFromBottom = stretchActionHandler.stretchViewConfiguration.initialMarginFromBottom
        
        let isOverInitialMarginFromBottom = stretchActionHandler.marginFromBottom > initialMarginFromBottom
        let isSlideUp = isOverInitialMarginFromBottom && translation.y < 0
        let factor = allowSlideDown && !isSlideUp ? StretchSpeed.default.rawValue : StretchSpeed.slow.rawValue
        stretchActionHandler.marginFromBottom -= translation.y * CGFloat(factor)

    }

    private func handleAppearanceBySlide(translation: CGPoint, velocity: CGPoint) {

        let marginFromBottom = stretchActionHandler.marginFromBottom
        let stretchViewMinimumHeight = stretchActionHandler.stretchViewConfiguration.minimumHeight

        if allowSlideDown, marginFromBottom + stretchViewMinimumHeight < stretchViewMinimumHeight * 0.6 {
            stretchActionHandler.disappear(animations: nil) { [weak self] in self?.delegate?.stretchHandlerDidDisappear() }
        } else {
            stretchActionHandler.appear(animations: nil) { [weak self] in self?.delegate?.stretchHandlerDidAppear() }
        }

    }

    private func handleStretch(translation: CGPoint, velocity: CGPoint, maximumHeight: CGFloat, minimumHeight: CGFloat) {
        delegate?.stretchHandler(
            translation: translation,
            velocity: velocity,
            didStretch: stretchActionHandler.height
        )

        if velocity.y < 0 {
            let isOverMaximumHeight = stretchActionHandler.height >= maximumHeight
            let stretchSpeed: StretchSpeed = isOverMaximumHeight ? .slow : .default
            stretchActionHandler.height += -translation.y * CGFloat(stretchSpeed.rawValue)
        } else {
            let isUnderMinimumHeight = stretchActionHandler.height < minimumHeight
            let stretchSpeed: StretchSpeed = isUnderMinimumHeight ? .slow : .default
            stretchActionHandler.height += -translation.y * CGFloat(stretchSpeed.rawValue)
        }
    }

    private func setStretchGestureHandlerAction(
        stretchViewConfiguration: StretchActionHandler.StretchViewConfiguration
    ) {
        stretchGestureHandler.reset(canScrollContent: stretchActionHandler.height >= stretchViewConfiguration.maximumHeight)

        stretchGestureHandler.stretch = { [weak self] item in
            guard let self else { return }

            let isStretchViewHeightMinimum = self.stretchActionHandler.height <= stretchViewConfiguration.minimumHeight
            let isPannedDown = item.translation.y > 0
            self.canSlide = self.canSlide ? true : isStretchViewHeightMinimum && isPannedDown

            if self.canSlide {
                self.handleSlide(translation: item.translation, velocity: item.velocity)
            } else {
                self.handleStretch(
                    translation: item.translation,
                    velocity: item.velocity,
                    maximumHeight: stretchViewConfiguration.maximumHeight,
                    minimumHeight: stretchViewConfiguration.minimumHeight
                )
            }
        }

        stretchGestureHandler.finishStretch = { [weak self] item in
            guard let self else { return }

            if self.canSlide {
                self.handleAppearanceBySlide(translation: item.translation, velocity: item.velocity)
            } else {
                self.delegate?.stretchHandler(
                    translation: item.translation,
                    velocity: item.velocity,
                    finishStretch: self.stretchActionHandler.height
                )
            }

            let canScrollContent = self.stretchActionHandler.height >= stretchViewConfiguration.maximumHeight
            self.stretchGestureHandler.canScrollContent = canScrollContent
            self.canSlide = false
        }
    }

}
