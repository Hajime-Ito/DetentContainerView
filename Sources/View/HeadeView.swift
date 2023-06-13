import UIKit

final class HeaderView: UIView {

    var barColor: UIColor = .secondaryLabel {
        didSet {
            headerBarView.backgroundColor = barColor
        }
    }

    static let headerHeight: CGFloat = 14
    static let barWidth: CGFloat = 36
    static let barHeight: CGFloat = 4.5

    override init(frame: CGRect) {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: HeaderView.headerHeight)
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var headerBarView: UIView = {
        let frame = CGRect(x: 0, y: 0, width: HeaderView.barWidth, height: 5)
        let view = UIView(frame: frame)
        view.backgroundColor = barColor
        view.isUserInteractionEnabled = true
        view.layer.cornerRadius = HeaderView.barWidth * 0.08
        view.clipsToBounds = true
        return view
    }()

    func add(on parentView: UIView) {
        parentView.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
        leadingAnchor.constraint(equalTo: parentView.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: parentView.trailingAnchor).isActive = true
        heightAnchor.constraint(equalToConstant: HeaderView.headerHeight).isActive = true

        addSubview(headerBarView)
        headerBarView.translatesAutoresizingMaskIntoConstraints = false
        headerBarView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        headerBarView.topAnchor.constraint(equalTo: topAnchor, constant: 5.5).isActive = true
        headerBarView.heightAnchor.constraint(equalToConstant: HeaderView.barHeight).isActive = true
        headerBarView.widthAnchor.constraint(equalToConstant: HeaderView.barWidth).isActive = true
    }

}
