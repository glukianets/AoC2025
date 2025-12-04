import Foundation
import Algorithms

class Day4A: DayCommand {
    typealias Input = [[Bool]]
    typealias Output = Int
    
    required init() { /**/ }

    func parseInput(_ input: String) throws -> Input {
        return try input.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { line in
                try line.unicodeScalars.map {
                    switch $0 {
                    case ".": return false
                    case "@": return true
                    default: throw "invalid input \(line): \($0) doesn't match."
                    }
                }
            }
    }
    
    static let vicinityDelta: [(Int, Int)] = (-1...1).flatMap { dx in (-1...1).map { dy in (dx, dy) } }
        .filter { $0 != (0, 0) }

    func vicinityIndices(_ input: Input, x: Int, y: Int) -> some Sequence<(Int, Int)> {
        Self.vicinityDelta.map { dx, dy in (dx + x, dy + y) }
            .filter { dx, dy in input.indices.contains(dx) && input[dx].indices.contains(dy) }
    }
    
    func mark(_ input: Input) -> Input {
        input.indexed().map { x, line in
            line.indexed().map { y, cell in
                cell && vicinityIndices(input, x: x, y: y).count { x, y in input[x][y] } < 4
            }
        }
    }
    
    func count(_ input: Input) -> Int {
        input.lazy.map { $0.count(where: \.self) }.reduce(0, +)
    }

    func run(_ input: Input) throws -> Output {
        self.count(self.mark(input))
    }
}

class Day4B: Day4A {
    override func run(_ input: Input) throws -> Output {
        sequence(state: input) { input in
            let markup = self.mark(input) // mark
            input = zip(input, markup).map { zip($0, $1).map { $0 && !$1 } } // sweep
            return apply(self.count(markup)) { $0 == 0 ? nil : $0 } // check
        }.reduce(0, +)
    }
}
