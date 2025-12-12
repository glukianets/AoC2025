import Foundation
import Algorithms

class Day11A: DayCommand {
    typealias Input = [Substring: [Substring]]
    typealias Output = Int

    required init() { /**/ }

    func parseInput(_ input: String) throws -> Input {
        let regex = /^(?<name>\w+):(?<outputs>(?:\s+\w+)+)\s*$/
        
        let pairs = try input
            .split { $0.isNewline }
            .map {
                guard let match = $0.wholeMatch(of: regex) else { throw "invalid line: \($0)" }
                return (match.output.name, match.output.outputs.split(separator: " "))
            }
        return .init(uniqueKeysWithValues: pairs)
    }
    
    func run(_ input: Input) throws -> Output {
        var search: ((Substring, Substring) -> Int?)!
        
        search = memoize { (target: Substring, current: Substring) -> Int? in
            current == target ? 1 : input[current]?.lazy.compactMap { search(target, $0) }.reduce(0, +)
        }
        
        return try search("out", "you").unwrapOr(throw: "Solution wasn't found")
    }
}

class Day11B: Day11A {
    override func run(_ input: Input) throws -> Output {
        var search: ((Substring, Substring) -> Int?)!
        
        search = memoize { (target: Substring, current: Substring) -> Int? in
            current == target ? 1 : input[current]?.lazy.compactMap { search(target, $0) }.reduce(0, +)
        }
        
        return [
            ["out", "dac", "fft", "svr"],
            ["out", "fft", "dac", "svr"],
        ].map { $0.adjacentPairs().map(search).map { $0 ?? 0 }.reduce(1, *) }.reduce(0, +)
    }
}
