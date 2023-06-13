import UIKit

final class BackgroundShadeView: UIView {
    
    enum ShadeTone: Float {
        case light = 0.2
        case normal = 0.4
        case dark = 0.6
    }

    var shadeTone: ShadeTone = .normal

    override init(frame: CGRect) {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        super.init(frame: frame)
        backgroundColor = .black
        alpha = 0.0
        isUserInteractionEnabled = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func add(on parentView: UIView, below subview: UIView) {
        parentView.insertSubview(self, belowSubview: subview)
        translatesAutoresizingMaskIntoConstraints = false
        parentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        parentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        parentView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        parentView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }

    func set(visibility: Bool) {
        if visibility {
            alpha = CGFloat(shadeTone.rawValue)
        } else {
            alpha = 0.0
        }
    }

    func remove() {
        isHidden = true
        removeFromSuperview()
    }

    func showShadeWithSlide(
        translation: CGPoint,
        velocity: CGPoint,
        showingViewHeight: CGFloat,
        backgroundShadeDisplayPosition: Detent,
        detentHandler: DetentHandler
    ) {
        guard let backgroundShadeDetentBelow = detentHandler.detents.registerd.below(backgroundShadeDisplayPosition) else { return }

         let backgroundShadeDetentHeight = detentHandler.detents.registerd.find(backgroundShadeDisplayPosition).height

         if velocity.y > 0 {
             if showingViewHeight > backgroundShadeDetentBelow.height, showingViewHeight < backgroundShadeDetentHeight {
                 var percentage = Float(translation.y / (showingViewHeight - backgroundShadeDetentBelow.height)) * 5000
                 percentage = ceil(percentage) / 100
                 disappear(percentage: percentage)
             }
         } else {
             if showingViewHeight < backgroundShadeDetentHeight, showingViewHeight > backgroundShadeDetentBelow.height {
                 var percentage = Float(-translation.y / (backgroundShadeDetentHeight - showingViewHeight)) * 5000
                 percentage = ceil(percentage) / 100
                 appear(percentage: percentage)
             }
         }
     }
}

// MARK: Private Method

extension BackgroundShadeView {

    private func appear(percentage: Float) {
        let percentage = CGFloat(percentage/100 * shadeTone.rawValue)
        let shadeTone = CGFloat(shadeTone.rawValue)

        if alpha + percentage > shadeTone {
            alpha = shadeTone
        } else {
            alpha += percentage
        }
    }
    
    private func disappear(percentage: Float) {
        let percentage = CGFloat(percentage/100 * shadeTone.rawValue)

        if alpha - percentage < 0.0 {
            alpha = 0.0
        } else {
            alpha -= percentage
        }
    }

}
