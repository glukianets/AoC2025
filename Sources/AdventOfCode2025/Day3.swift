import Foundation
import Algorithms

class Day3A: DayCommand {
    typealias Input = [[Int]]
    typealias Output = Int
    
    required init() { /**/ }

    func parseInput(_ input: String) throws -> Input {
        try input.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { line in
                try line.unicodeScalars.map {
                    guard $0.isASCII && (0x30...0x39).contains($0.value) else {
                        throw "invalid input: \(line); \($0) is not a digit"
                    }
                    return Int($0.value - 0x30)
                }
            }
    }
    
    var limit: Int { 2 }
    
    func run(_ input: Input) throws -> Output {
        input.reduce(into: 0) { a, battarray in
            a += battarray.indexed().reduce(into: [] as [Int]) { a, e in
                let i = max(a.partitioningIndex { $0 < e.element }, limit + e.index - battarray.endIndex)
                guard i < limit else { return }
                a.replaceSubrange(i..., with: CollectionOfOne(e.element))
            }.reduce(0) { $0 * 10 + $1 }
        }
    }
}

class Day3B: Day3A {
    override var limit: Int { 12 }
}
