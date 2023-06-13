import UIKit

final class BlurEffecteBackgroundView: UIVisualEffectView {

    override init(effect: UIVisualEffect?) {
        super.init(effect: effect)
        frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func add(on parentView: UIView) {
        parentView.add(contentView: self, topPadding: 0)
        parentView.sendSubviewToBack(self)
    }
}
