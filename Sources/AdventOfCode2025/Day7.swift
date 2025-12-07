import Foundation
import Algorithms

class Day7A: DayCommand {
    typealias Input = (entry: [Int], manifold: [[Bool]])
    typealias Output = Int
        
    required init() { /**/ }

    func parseInput(_ input: String) throws -> Input {
        let lines = input.split(omittingEmptySubsequences: true) { $0.isWhitespace }
        guard let firstLine = lines.first, lines.count > 2 else { throw "Invalid input \(lines)" }
        let manifold: [[Bool]] = try lines.dropFirst().map { line in
            try line.map {
                switch $0 {
                case ".": return false
                case "^": return true
                default: throw "Invalid character \($0) in \(line)"
                }
            }
        }
        
        let entry: [Int] = try firstLine.map {
            switch $0 {
            case ".": return 0
            case "S": return 1
            default: throw "Invalid character \($0) in \(firstLine)"
            }
        }
        
        guard
            entry.contains(where: { $0 > 0 }),
            manifold.lazy.map(\.count).adjacentPairs().allSatisfy(==),
            manifold.first!.count == entry.count
        else { throw "invalid first line \(firstLine)" }
        
        return (entry, manifold)
    }
    
    func fold(left: Int, middle: Int, right: Int) -> Int {
        middle + left + right.signum()
    }
    
    func run(_ input: Input) throws -> Output {
        input.manifold.reduce(input.entry) { a, e in
            a.indices.map { i in
                return e[i] ? 0 : fold(
                    left: i < 1 ? 0 : e[i - 1] ? a[i - 1] : 0,
                    middle: a[i],
                    right: i > a.count - 2 ? 0 : e[i + 1] ? a[i + 1] : 0,
                )
            }
        }.reduce(0, +) - 1 // we need to offset the initial 1 in entry
    }
}

class Day7B: Day7A {
    override func fold(left: Int, middle: Int, right: Int) -> Int {
        middle + left + right
    }
    
    override func run(_ input: Input) throws -> Output {
        try super.run(input) + 1
    }
}
