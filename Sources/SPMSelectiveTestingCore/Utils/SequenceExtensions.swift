

public extension Sequence {
    func exclude(_ isExcluded: (Self.Element) throws -> Bool) rethrows -> [Self.Element] {
        try filter { try !isExcluded($0) }
    }
}
