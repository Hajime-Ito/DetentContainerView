import UIKit

public enum Detent {
    case top(height: CGFloat?, heightRatio: CGFloat? = nil)
    case upper(height: CGFloat?, heightRatio: CGFloat? = nil)
    case lower(height: CGFloat?, heightRatio: CGFloat? = nil)
    case bottom(height: CGFloat?, heightRatio: CGFloat? = nil)
}

extension Detent {

    public func height(from maximumHeight: CGFloat) -> CGFloat {
        switch self {
        case let .top(height, heightRatio):
            if let height = height { return height }
            if let heightRatio = heightRatio { return heightRatio * maximumHeight }
            return 0

        case let .upper(height, heightRatio):
            if let height = height { return height }
            if let heightRatio = heightRatio { return heightRatio * maximumHeight }
            return 0

        case let .lower(height, heightRatio):
            if let height = height { return height }
            if let heightRatio = heightRatio { return heightRatio * maximumHeight }
            return 0

        case let .bottom(height, heightRatio):
            if let height = height { return height }
            if let heightRatio = heightRatio { return heightRatio * maximumHeight }
            return 0
        }
    }

    public static var topType: Detent { .top(height: nil) }
    public static var upperType: Detent { .upper(height: nil) }
    public static var lowerType: Detent { .lower(height: nil) }
    public static var bottomType: Detent { .bottom(height: nil) }

}

extension Detent: Comparable {

    public static func == (lhs: Detent, rhs: Detent) -> Bool {
        switch (lhs, rhs) {
        case (.top, .top):
            return true
        case (.upper, .upper):
            return true
        case (.lower, .lower):
            return true
        case (.bottom, .bottom):
            return true
        default:
            return false
        }
    }

    public static func < (lhs: Detent, rhs: Detent) -> Bool {
        switch lhs {
        case .top:
            return false
        case .upper:
            switch rhs {
            case .top:
                return true
            default:
                return false
            }
        case .lower:
            switch rhs {
            case .top, .upper:
                return true
            default:
                return false
            }
        case .bottom:
            switch rhs {
            case .top, .upper, .lower:
                return true
            default:
                return false
            }
        }
    }

}

extension Array where Element == Detent {

    public func find(_ detent: Detent) -> Detent {
        self.first { $0 == detent } ?? detent
    }

    public var top: Detent {
        if self.contains(.topType) { return find(.topType) }
        if self.contains(.upperType) { return find(.upperType) }
        if self.contains(.lowerType) { return find(.lowerType) }
        return find(.bottomType)
    }

    public var bottom: Detent {
        if self.contains(.bottomType) { return find(.bottomType) }
        if self.contains(.lowerType) { return find(.lowerType) }
        if self.contains(.upperType) { return find(.upperType) }
        return find(.topType)
    }

    public func above(_ detent: Detent) -> Detent? {
        switch detent {
        case .top:
            return nil
        case .upper:
            if self.contains(.topType) { return find(.topType) }
            return nil
        case .lower:
            if self.contains(.upperType) { return find(.upperType) }
            if self.contains(.topType) { return find(.topType) }
            return nil
        case .bottom:
            if self.contains(.lowerType) { return find(.lowerType) }
            if self.contains(.upperType) { return find(.upperType) }
            if self.contains(.topType) { return find(.topType) }
            return nil
        }
    }

    public func below(_ detent: Detent) -> Detent? {
        switch detent {
        case .top:
            if self.contains(.upperType) { return find(.upperType) }
            if self.contains(.lowerType) { return find(.lowerType) }
            if self.contains(.bottomType) { return find(.bottomType) }
            return nil
        case .upper:
            if self.contains(.lowerType) { return find(.lowerType) }
            if self.contains(.bottomType) { return find(.bottomType) }
            return nil
        case .lower:
            if self.contains(.bottomType) { return find(.bottomType) }
            return nil
        case .bottom:
            return nil
        }
    }

}
