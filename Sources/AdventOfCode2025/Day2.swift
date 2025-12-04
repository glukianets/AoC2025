import Foundation
import Algorithms

class Day2A: DayCommand, @unchecked Sendable {
    typealias Input = [ClosedRange<Int>]
    typealias Output = Int
    
    required init() { /**/ }

    static let pow10: [Int] = (0..<18).reductions(1) { a, e in a * 10 }

    func parseInput(_ input: String) throws -> Input {
        return try input.components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map {
                let components = $0.components(separatedBy: "-")
                guard
                    components.count == 2,
                    let lowerBound = Int(components[0]),
                    let upperBound = Int(components[1]),
                    lowerBound <= upperBound
                else { throw "invalid input: \($0)" }
                
                return lowerBound...upperBound
            }
    }

    func run(_ input: Input) async throws -> Output {
        await input.parallelMap {
            $0.lazy.filter(self.isInvalid(_:)).reduce(0, +)
        }.reduce(0, +)
    }

    func isInvalid(_ x: Int) -> Bool {
        let d = Int(log10(Double(x)))
        let base = Self.pow10[d / 2 + 1]
        return d % 2 != 0 && x % base == x / base
    }
}

class Day2B: Day2A, @unchecked Sendable {
    override func isInvalid(_ n: Int) -> Bool {
        guard n > 10 else { return false }
        
        outer: for m in 1..<Self.pow10.count {
            let base = Self.pow10[m]
            guard n > base else { break }
            let block = n % base
            guard block >= Self.pow10[m - 1] else { continue }
            var tmp = n
            while tmp > 0 {
                guard tmp % base == block else { continue outer }
                tmp /= base
            }
            return true
        }
        return false
    }
}
