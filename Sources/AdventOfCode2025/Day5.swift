import Foundation
import Algorithms

class Day5A: DayCommand {
    typealias Input = (fresh: [Range<Int>], available: [Int])
    typealias Output = Int
    
    required init() { /**/ }

    func parseInput(_ input: String) throws -> Input {
        let sections = input.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .split(separator: "", maxSplits: 1, omittingEmptySubsequences: true)
        
        guard sections.count == 2 else {
            throw "invalid input: \(input)"
        }
        
        let fresh = try sections[0].map { line in
            guard
                let matches = line.firstMatch(of: /^(\d+)-(\d+)$/),
                let lower = Int(matches.1),
                let upper = Int(matches.2),
                upper < .max && lower <= upper
            else {
                throw "invalid input: \(line)"
            }
            return lower..<upper+1
        }
        let available = try sections[1].map { line in
            guard let number = Int(line) else {
                throw "invalid input: \(line)"
            }
            return number
        }
        return (fresh, available)
    }
    
    func run(_ input: Input) throws -> Output {
        input.available.count(where: RangeSet(input.fresh).contains(_:))
    }
}

class Day5B: Day5A {
    override func run(_ input: Input) throws -> Output {
        return RangeSet(input.fresh).ranges.lazy.map(\.count).reduce(0, +)
    }
}
