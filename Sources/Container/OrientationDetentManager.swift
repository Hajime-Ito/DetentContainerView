struct OrientationDetentManager {

    enum Orientation {
        case portrait
        case landscape
    }

    var orientation: Orientation

    var currentHandler: DetentHandler {
        switch orientation {
        case .portrait: return portraitDetentHandler
        case .landscape: return landscapeDetentHandler
        }
    }

    var currentBackgroundShadeDisplayPosition: Detent? {
        switch orientation {
        case .portrait: return portraitBackgroundShadeDisplayPosition
        case .landscape: return landscapeBackgroundShadeDisplayPosition
        }
    }

    var shouldDisplayBackgroundShade: Bool {
        switch orientation {
        case .portrait:
            guard let position = portraitBackgroundShadeDisplayPosition else { return false }
            if portraitDetentHandler.detents.current >= position { return true }
            return false

        case .landscape:
            guard let position = landscapeBackgroundShadeDisplayPosition else { return false }
            if landscapeDetentHandler.detents.current >= position { return true }
            return false
        }
    }

    private let portraitDetentHandler: DetentHandler
    private let landscapeDetentHandler: DetentHandler
    private let portraitBackgroundShadeDisplayPosition: Detent?
    private let landscapeBackgroundShadeDisplayPosition: Detent?

    init(
        orientation: Orientation,
        portraitDetents: Detents,
        landscapeDetents: Detents,
        portraitBackgroundShadeDisplayPosition: Detent?,
        landscapeBackgroundShadeDisplayPosition: Detent?
    ) {
        self.orientation = orientation
        self.portraitDetentHandler = DetentHandler(detents: portraitDetents)
        self.landscapeDetentHandler = DetentHandler(detents: landscapeDetents)
        self.portraitBackgroundShadeDisplayPosition = portraitBackgroundShadeDisplayPosition
        self.landscapeBackgroundShadeDisplayPosition = landscapeBackgroundShadeDisplayPosition
    }

}
