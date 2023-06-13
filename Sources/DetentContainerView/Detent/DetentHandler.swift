import UIKit

final class DetentHandler {

    var isLocked: Bool = false
    var detents: Detents

    private static let thresholdVelocityToChangeDetent: CGFloat = 500.0

    init(detents: Detents) {
        self.detents = detents
    }

    func raise() {
        guard !isLocked else { return }
        detents.raise()
    }

    func lower() {
        guard !isLocked else { return }
        detents.lower()
    }

    func changeDetentByPan(velocity: CGPoint, showingViewHeight: CGFloat) {
        guard !isLocked else { return }

        if velocity.y > DetentHandler.thresholdVelocityToChangeDetent {
            lower()
            return
        }

        if velocity.y < -DetentHandler.thresholdVelocityToChangeDetent {
            raise()
            return
        }

        detents.current = getNextDetent(by: showingViewHeight)
    }

}

extension DetentHandler {

    private func getNextDetent(by showingViewHeight: CGFloat) -> Detent {
        if showingViewHeight > detents.registerd.top.height { return detents.registerd.top }
        if showingViewHeight < detents.registerd.bottom.height { return detents.registerd.bottom }
        
        var checkDetent = detents.registerd.top
        while true {
            guard let belowCheckDetent = detents.registerd.below(checkDetent) else { break }
            let centerHeight = belowCheckDetent.height + (checkDetent.height - belowCheckDetent.height) / 2
            if showingViewHeight >= centerHeight && showingViewHeight <= checkDetent.height { return checkDetent }
            if showingViewHeight < centerHeight && showingViewHeight >= belowCheckDetent.height { return belowCheckDetent }
            checkDetent = belowCheckDetent
        }
        return detents.registerd.bottom
    }

}
