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
        isInvalidOptimal(id)
    }
    
    func isInvalidIdiomatic(_ id: Int) -> Bool {
        guard id > 9 else { return false }

        let digits = Array(id.digits)
        let lengths = (1...digits.count/2).lazy.filter { digits.count % $0 == 0 }
        return lengths.contains { digits.chunks(ofCount: $0).lazy.adjacentPairs().allSatisfy(==) }
    }

    func isInvalidOptimal(_ id: Int) -> Bool {
        let digits = Array(id.digits)
        
        outer: for index in digits.indices.dropFirst().prefix(digits.count / 2) {
            let distance = digits.distance(from: digits.startIndex, to: index)
            guard digits.count % distance == 0 else { continue outer }
            
            for i in 1 ..< digits.count / distance {
                let range = index.advanced(by: distance * (i - 1)) ..< index.advanced(by: distance * i)
                guard digits[range] == digits[..<index] else { continue outer }
            }
            return true
        }
        return false
    }
}

private extension BinaryInteger {
    var digitCount: Int {
        Int(floor(log10(2) * Float(self.bitWidth)) + 1)
    }
    
    var digits: some Sequence<Self> {
        sequence(state: self) { value in
            guard value != 0 else { return nil }
            defer { value /= 10 }
            return value % 10
        }
    }
}
