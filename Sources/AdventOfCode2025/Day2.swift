import Foundation
import Algorithms

class Day2A: DayCommand {
    typealias Input = [ClosedRange<Int>]
    typealias Output = Int
    
    required init() { /**/ }

    func parseInput(_ input: String) throws -> Input {
        return try input.components(separatedBy: CharacterSet(charactersIn: ","))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map {
                guard
                    let match = $0.wholeMatch(of: /^(\d+)-(\d+)$/),
                    let lowerBound = Int(match.1),
                    let upperBound = Int(match.2),
                    lowerBound <= upperBound
                else { throw "invalid input: \($0)" }
                
                return lowerBound...upperBound
            }
    }

    func run(_ input: Input) throws -> Output {
        input.lazy.flatMap { $0 }.filter(self.isInvalid(_:)).reduce(0, +)
    }
    
    func isInvalid(_ id: Int) -> Bool {
        let digits = Array(id.digits)
        let midpoint = digits.count / 2
        return digits[..<midpoint] == digits[midpoint...]
    }
}

class Day2B: Day2A {
    override func isInvalid(_ id: Int) -> Bool {
        guard id > 9 else { return false }

        let digits = Array(id.digits)
        let candidateLengths = (1...digits.count/2).lazy.filter { digits.count % $0 == 0 }.reversed()
        return candidateLengths.contains { length in digits.chunks(ofCount: length).adjacentPairs().allSatisfy(==) }
    }
}

private extension BinaryInteger {
    var digits: some Sequence<Self> {
        sequence(state: self) { value in
            guard value != 0 else { return nil }
            defer { value /= 10 }
            return value % 10
        }
    }
}
