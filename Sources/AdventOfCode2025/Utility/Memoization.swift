import Swift

func memoize<each T, R>(_ function: @escaping (repeat each T) -> R) -> (repeat each T) -> R
where repeat each T: Hashable {
    var cache: [CacheKey<repeat each T>: R] = [:]

    return { (args: repeat each T) -> R in
        let key = CacheKey(repeat each args)

        if let cached = cache[key] {
            return cached
        } else {
            let result = function(repeat each args)
            cache[key] = result
            return result
        }
    }
}

func memoize<each T, R, E>(_ function: @escaping (repeat each T) throws(E) -> R) -> (repeat each T) throws(E) -> R
where repeat each T: Hashable {
    var cache: [CacheKey<repeat each T>: Result<R, E>] = [:]

    return { (args: repeat each T) throws(E) -> R in
        let key = CacheKey(repeat each args)

        if let cached = cache[key] {
            return try cached.get()
        } else {
            do {
                let result = try function(repeat each args)
                cache[key] = .success(result)
                return result
            } catch let error as E {
                cache[key] = .failure(error)
                throw error
            } catch {
                fatalError("Unexpected error of unknown type: \(error)")
            }
        }
    }
}

private struct CacheKey<each T>: Hashable where repeat each T: Hashable {
    private let values: (repeat each T)

    init(_ values: repeat each T) {
        self.values = (repeat each values)
    }

    func hash(into hasher: inout Hasher) {
        repeat (each values).hash(into: &hasher)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        for (l, r) in repeat (each lhs.values, each rhs.values) {
            guard l == r else { return false }
        }
        return true
    }
}
