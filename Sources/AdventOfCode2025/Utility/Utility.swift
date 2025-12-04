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
            guard case let .some(wrapped) = self else {
                throw "Failed to unwrap optional of type \(Self.self)"
            }
            return wrapped
        }
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

extension Collection {
    func parallelMap<T: Sendable>(
        parallelism requestedParallelism: Int? = nil,
        _ transform: @Sendable @escaping (Element) async throws -> T
    ) async rethrows -> [T] where Self.Index: Sendable, Self.Element: Sendable {
        let defaultParallelism = 2
        let parallelism = requestedParallelism ?? defaultParallelism

        let n = count
        if n == 0 {
            return []
        }
        return try await withThrowingTaskGroup(of: (Int, T).self, returning: [T].self) { group in
            var result = [T?](repeatElement(nil, count: n))

            var i = self.startIndex
            var submitted = 0

            func submitNext() async throws {
                if i == self.endIndex { return }
                let value = self[i]
                group.addTask { [submitted, value] in
                    let value = try await transform(value)
                    return (submitted, value)
                }
                submitted += 1
                formIndex(after: &i)
            }

            for _ in 0 ..< parallelism {
                try await submitNext()
            }

            while let (index, taskResult) = try await group.next() {
                result[index] = taskResult

                try Task.checkCancellation()
                try await submitNext()
            }

            assert(result.count == n)
            return Array(result.compactMap { $0 })
        }
    }
}
