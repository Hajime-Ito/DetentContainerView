import UIKit

public enum Detent {
    case top(height: CGFloat)
    case upper(height: CGFloat)
    case lower(height: CGFloat)
    case bottom(height: CGFloat)
}

extension Detent {

    public var height: CGFloat {
        switch self {
        case let .top(height): return height
        case let .upper(height): return height
        case let .lower(height): return height
        case let .bottom(height): return height
        }
    }

    public static var topType: Detent { .top(height: .zero) }
    public static var upperType: Detent { .upper(height: .zero) }
    public static var lowerType: Detent { .lower(height: .zero) }
    public static var bottomType: Detent { .bottom(height: .zero) }

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
