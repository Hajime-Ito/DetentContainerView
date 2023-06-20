import UIKit

public protocol DetentContainerViewDelegate: NSObject {

    func detentContainerView(_ view: DetentContainerView, didChangeDetent detent: Detent)
    func detentContainerView(_ view: DetentContainerView, didChangeDetentAnimation detent: Detent)
    func detentContainerView(_ view: DetentContainerView, didFinishChangeDetentAnimation detent: Detent)

}

public final class DetentContainerView: RotatableView {

    public var marginFromSideEdge: CGFloat = 5
    public var headerBarColor: UIColor = .secondaryLabel {
        didSet { headerView.barColor = headerBarColor }
    }

    public weak var delegate: DetentContainerViewDelegate?

    private var maximumHeight: CGFloat = 0
    private var marginFromBottom: CGFloat = 0
    private var viewDidRotated = true
    private var headerView = HeaderView()
    private var blurEffecteBackgroundView = BlurEffecteBackgroundView()
    private var backgroundShadeView = BackgroundShadeView()
    private var detentManager: OrientationDetentManager?
    private var stretchHandler: StretchHandler?

    override init(frame: CGRect) {
        let frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: frame.height)
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
        layer.cornerRadius = 16
        clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
        layer.cornerRadius = 16
        clipsToBounds = true
    }

    override var _marginFromSideEdge: CGFloat { marginFromSideEdge }

    override public func layoutSubviews() {
        super.layoutSubviews()

        guard let detentManager = detentManager, let window, viewDidRotated else { return }

        marginFromBottom = window.safeAreaInsets.bottom == 0 ? 10 : 0
        maximumHeight = window.screen.bounds.height - window.safeAreaInsets.bottom - window.safeAreaInsets.top - marginFromBottom * 2
        let configuration = createStretchViewConfiguration(detents: detentManager.currentHandler.detents)
        stretchHandler?.set(stretchViewConfiguration: configuration)

        if !isHidden {
            let currentHeight = detentManager.currentHandler.detents.current.height(from: maximumHeight) + marginFromBottom
            stretchHandler?.appear(
                height: currentHeight,
                animations: { [weak self] in
                    self?.backgroundShadeView.set(visibility: detentManager.shouldDisplayBackgroundShade)
                },
                completion: nil
            )
        }

        viewDidRotated = false
    }

    override func viewDidRotated(currentOrientation: UIDeviceOrientation, previousOrientation: UIDeviceOrientation?) {
        super.viewDidRotated(currentOrientation: currentOrientation, previousOrientation: previousOrientation)
        detentManager?.orientation = currentOrientation == .portrait ? .portrait : .landscape
        viewDidRotated = true
    }

    public func configure(
        contentViewController: UIViewController,
        portraitDetents: Detents,
        landscapeDetents: Detents,
        allowSlideDown: Bool = true,
        blurEffecte: UIBlurEffect? = nil,
        portraitBackgroundShadeDisplayPosition: Detent? = nil,
        landscapeBackgroundShadeDisplayPosition: Detent? = nil,
        landscapeConfiguration: LandscapeConfiguration = LandscapeConfiguration(position: .trailing, width: 340)
    ) {
        self.landscapeConfiguration = landscapeConfiguration
        add(contentViewController: contentViewController, topPadding: HeaderView.headerHeight)
        configure(
            portraitDetents: portraitDetents,
            landscapeDetents: landscapeDetents,
            allowSlideDown: allowSlideDown,
            blurEffecte: blurEffecte,
            portraitBackgroundShadeDisplayPosition: portraitBackgroundShadeDisplayPosition,
            landscapeBackgroundShadeDisplayPosition: landscapeBackgroundShadeDisplayPosition
        )
    }

    public func configure(
        contentView: UIView,
        portraitDetents: Detents,
        landscapeDetents: Detents,
        allowSlideDown: Bool = true,
        blurEffecte: UIBlurEffect? = nil,
        portraitBackgroundShadeDisplayPosition: Detent? = nil,
        landscapeBackgroundShadeDisplayPosition: Detent? = nil,
        landscapeConfiguration: LandscapeConfiguration = LandscapeConfiguration(position: .trailing, width: 340)
    ) {
        self.landscapeConfiguration = landscapeConfiguration
        add(contentView: contentView, topPadding: HeaderView.headerHeight)
        configure(
            portraitDetents: portraitDetents,
            landscapeDetents: landscapeDetents,
            allowSlideDown: allowSlideDown,
            blurEffecte: blurEffecte,
            portraitBackgroundShadeDisplayPosition: portraitBackgroundShadeDisplayPosition,
            landscapeBackgroundShadeDisplayPosition: landscapeBackgroundShadeDisplayPosition
        )
    }

    public func stretch(to height: CGFloat, animations: (() -> Void)?, completion: (() -> Void)?) {
        stretchHandler?.stretch(to: height, animations: animations, completion: completion)
    }

    public func appear(height: CGFloat, animations: (() -> Void)?, completion: (() -> Void)?) {
        if let superview = superview {
            backgroundShadeView.remove()
            backgroundShadeView.add(on: superview, below: self)
        }
        stretchHandler?.appear(height: height, animations: animations, completion: completion)
    }

    public func disappear(animations: (() -> Void)?, completion: (() -> Void)?) {
        stretchHandler?.disappear(animations: animations, completion: completion)
    }

}

// - MARK: StretchHandlerDelegate

extension DetentContainerView: StretchHandlerDelegate {

    func stretchHandler(translation: CGPoint, velocity: CGPoint, didStretch viewHeight: CGFloat) {
        guard let detentManager = detentManager else { return }
        guard let backgroundShadeDisplayPosition = detentManager.currentBackgroundShadeDisplayPosition else { return }

        let aboveDetent = detentManager.currentHandler.detents.aboveCurrent
        let belowDetent = detentManager.currentHandler.detents.belowCurrent

        if let nextDetent = translation.y > 0 ? belowDetent : aboveDetent {
            delegate?.detentContainerView(
                self,
                didChangeDetent: nextDetent
            )
        }

        backgroundShadeView.showShadeWithSlide(
            translation: translation,
            velocity: velocity,
            showingViewHeight: viewHeight,
            screenHeight: maximumHeight,
            backgroundShadeDisplayPosition: backgroundShadeDisplayPosition,
            detentHandler: detentManager.currentHandler
        )
    }

    func stretchHandler(translation: CGPoint, velocity: CGPoint, finishStretch viewHeight: CGFloat) {
        guard let detentManager = detentManager else { return }
        detentManager.currentHandler.changeDetentByPan(velocity: velocity, showingViewHeight: viewHeight, screenHeight: maximumHeight)

        let currentHeight = detentManager.currentHandler.detents.current.height(from: maximumHeight) + marginFromBottom
        stretchHandler?.stretch(
            to: currentHeight,
            animations: { [weak self] in
                guard let self else { return }
                self.delegate?.detentContainerView(self, didChangeDetentAnimation: detentManager.currentHandler.detents.current)
                self.backgroundShadeView.set(visibility: detentManager.shouldDisplayBackgroundShade)
            },
            completion: { [weak self] in
                guard let self else { return }
                self.delegate?.detentContainerView(self, didFinishChangeDetentAnimation: detentManager.currentHandler.detents.current)
            }
        )
    }

    func stretchHandlerDidDisappear() {
        backgroundShadeView.remove()
    }

    func stretchHandlerDidAppear() { }

}

// - MARK: Private function

extension DetentContainerView {

    private func configure(
        portraitDetents: Detents,
        landscapeDetents: Detents,
        allowSlideDown: Bool,
        blurEffecte: UIBlurEffect?,
        portraitBackgroundShadeDisplayPosition: Detent?,
        landscapeBackgroundShadeDisplayPosition: Detent?
    ) {
        detentManager = OrientationDetentManager(
            orientation: .portrait,
            portraitDetents: portraitDetents,
            landscapeDetents: landscapeDetents,
            portraitBackgroundShadeDisplayPosition: portraitBackgroundShadeDisplayPosition,
            landscapeBackgroundShadeDisplayPosition: landscapeBackgroundShadeDisplayPosition
        )

        if let detents = detentManager?.currentHandler.detents {
            let configuration = createStretchViewConfiguration(detents: detents)
            let handler = StretchHandler(
                stretchView: self,
                stretchViewConfiguration: configuration,
                allowSlideDown: allowSlideDown
            )
            handler.delegate = self
            stretchHandler = handler
        }

        if let superview = superview {
            backgroundShadeView.add(on: superview, below: self)
        }

        if let blurEffecte {
            backgroundColor = .clear
            blurEffecteBackgroundView.effect = blurEffecte
            blurEffecteBackgroundView.add(on: self)
            blurEffecteBackgroundView.isHidden = false
        }

        headerView.add(on: self)
    }

    private func createStretchViewConfiguration(detents: Detents) -> StretchActionHandler.StretchViewConfiguration {
        StretchActionHandler.StretchViewConfiguration(
            initialHeight: detents.current.height(from: maximumHeight) + marginFromBottom,
            minimumHeight: detents.registerd.bottom.height(from: maximumHeight) + marginFromBottom,
            maximumHeight: detents.registerd.top.height(from: maximumHeight) + marginFromBottom,
            initialMarginFromBottom: marginFromBottom
        )
    }

}
