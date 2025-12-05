import Foundation
import Algorithms

class Day1A: DayCommand {
    typealias Input = [Int]
    typealias Output = Int
    
    required init() { /**/ }

    func parseInput(_ input: String) throws -> Input {
        try input.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .map {
                guard let count = Int($0.dropFirst()) else { throw "Invalid input: \($0)" }
                assert(count != 0)

                switch $0.first! {
                case "L": return -count
                case "R": return count
                default: throw "Invalid input: \($0)"
                }
            }
    }

    func run(_ input: Input) throws -> Output {
        input.reductions(into: 50) { $0 = ($0 + $1 + 100) % 100 }.count { $0 == 0 }
    }
}

class Day1B: Day1A {
    override func run(_ input: Input) throws -> Output {
        input.reduce(into: (current: 50, zeroes: 0)) { a, e in
            a.zeroes += (e < 0 ? (100 - a.current) % 100 + abs(e) : a.current + e) / 100
            a.current = (a.current + e % 100 + 100) % 100
        }.zeroes
    }
}
