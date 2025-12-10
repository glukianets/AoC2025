import Foundation

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
