public struct Detents {
    public var registerd: [Detent]
    public var current: Detent

    public init(registerd: [Detent]) {
        if registerd.isEmpty { fatalError("Do not set an empty array for 'detents'") }
        self.registerd = registerd
        self.current = registerd.first!
    }
}

extension Detents {

    public var aboveCurrent: Detent? { registerd.above(current) }
    
    public var belowCurrent: Detent? { registerd.below(current) }

    public mutating func raise() {
        current = registerd.above(current) ?? current
    }
    
    public mutating func lower() {
        current = registerd.below(current) ?? current
    }

}
