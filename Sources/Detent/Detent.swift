import UIKit

public enum Detent {
    case top(heightRatio: CGFloat)
    case upper(heightRatio: CGFloat)
    case lower(heightRatio: CGFloat)
    case bottom(heightRatio: CGFloat)
}

extension Detent {

    public func height(from maximumHeight: CGFloat) -> CGFloat {
        switch self {
        case let .top(heightRatio): return maximumHeight * heightRatio
        case let .upper(heightRatio): return maximumHeight * heightRatio
        case let .lower(heightRatio): return maximumHeight * heightRatio
        case let .bottom(heightRatio): return maximumHeight * heightRatio
        }
    }

    public static var topType: Detent { .top(heightRatio: .zero) }
    public static var upperType: Detent { .upper(heightRatio: .zero) }
    public static var lowerType: Detent { .lower(heightRatio: .zero) }
    public static var bottomType: Detent { .bottom(heightRatio: .zero) }

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
