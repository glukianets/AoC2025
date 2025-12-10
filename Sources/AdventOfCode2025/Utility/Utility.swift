import Foundation

extension String: @retroactive Error {}

func apply<each T, R, E>(_ value: repeat each T, transform: (repeat each T) throws(E) -> R) throws(E) -> R {
    try transform(repeat each value)
}

func apply<each T, R, E>(_ value: repeat each T, transform: (repeat each T) async throws(E) -> R) async throws(E) -> R {
    try await transform(repeat each value)
}

extension Optional {
    var unwrapped: Wrapped {
        get throws {
            try self.unwrapOr(throw: "Failed to unwrap optional of type \(Self.self)")
        }
    }
    
    func unwrapOr<E>(throw error: E) throws(E) -> Wrapped {
        guard let self else { throw error }
        return self
    }
}

precedencegroup PowerPrecedence {
    higherThan: MultiplicationPrecedence
}

infix operator ^^: PowerPrecedence

func ^^<T: BinaryInteger>(radix: T, power: T) -> T {
    T(pow(Double(radix), Double(power)))
}

func *<C1, C2>(_ lhs: C1, _ rhs: C2) -> AnyCollection<(C1.Element, C2.Element)>
where C1: Collection, C2: Collection {
    AnyCollection(lhs.lazy.flatMap { l in rhs.lazy.map { r in (l, r) } })
}

extension ClosedRange {
    func intersection(with other: ClosedRange) -> ClosedRange? {
        let lowerBound = Swift.max(self.lowerBound, other.lowerBound)
        let upperBound = Swift.min(self.upperBound, other.upperBound)
        return lowerBound <= upperBound ? lowerBound...upperBound : nil
    }
}

func memoized<I: Hashable, O>(_ f: @escaping (I) throws -> O) -> (I) throws -> O {
    var cache: [I: O] = [:]
    return { input in
        if let output = cache[input] {
            return output
        } else {
            let output = try f(input)
            cache[input] = output
            return output
        }
    }
}

func memoized<I: Hashable, O>(_ f: @escaping (I) -> O) -> (I) -> O {
    let f = memoized(f as (I) throws -> O)
    return { try! f($0) }
}


public struct Peekable<Iterator: IteratorProtocol>: IteratorProtocol {
    public typealias Element = Iterator.Element
    
    private var iterator: Iterator
    private var nextElement: Element? = nil
    
    init(_ iterator: Iterator) {
        self.iterator = iterator
        self.nextElement = self.iterator.next()
    }
    
    public func peek() -> Element? {
        self.nextElement
    }
    
    public mutating func next() -> Element? {
        defer { self.nextElement = self.iterator.next() }
        return self.nextElement
    }
}

extension Peekable: Equatable where Iterator: Equatable {
    public static func == (lhs: Peekable<Iterator>, rhs: Peekable<Iterator>) -> Bool {
        lhs.iterator == rhs.iterator
    }
}

extension Peekable: Comparable where Iterator: Comparable {
    public static func < (lhs: Peekable<Iterator>, rhs: Peekable<Iterator>) -> Bool {
        lhs.iterator == rhs.iterator
    }
}

extension IteratorProtocol {
    public var peekable: Peekable<Self> {
        .init(self)
    }
}

extension Collection where Element: Collection {
    var indices2d: some Sequence<(y: Index, x: Element.Index)> {
        self.indices.lazy.flatMap { y in self[y].indices.map { x in (y: y, x: x) } }
    }
}

extension ExpressibleByIntegerLiteral {
    init(boolean: BooleanLiteralType) {
        self = boolean ? 1 : 0
    }
}

extension Strideable {
    mutating func advancing(by n: Stride, returningOldValue: Bool = false) -> Self {
        self = self.advanced(by: n)
        return self
    }
    
    mutating func advance(by n: Stride, returningOldValue: Bool = false) -> Self {
        defer { self = self.advanced(by: n) }
        return self
    }
}
