import Foundation
import Algorithms
import Collections
import simd

class Day10A: DayCommand {
    typealias Input = [Machine]
    typealias Output = Int
    
    typealias Machine = (state: State, buttons: Buttons, joltage: Joltage)
    typealias State = [Bool]
    typealias Buttons = [[State.Index]]
    typealias Joltage = [Int]
    

    required init() { /**/ }

    func parseInput(_ input: String) throws -> Input {
        let regex = /^\[(?<brackets>[.#]+)\](?<parens>(?:\s+\(\d+(?:,\d+)*\))+)\s+\{(?<braces>\d+(?:,\d+)*)\}$/
        
        return try input
            .split(omittingEmptySubsequences: true) { $0.isNewline }
            .map {
                guard let match = $0.wholeMatch(of: regex) else { throw "invalid line: \($0)" }
                
                let state: State = match.output.brackets.map { $0 == "#" }
                let buttons: Buttons = match.output.parens.split(omittingEmptySubsequences: true) { $0.isWhitespace }
                    .map { $0.dropFirst().dropLast().split(separator: ",").map { Int($0)! } }
                let jolts: Joltage = match.output.braces.split(separator: ",").map { Int($0)! }
                
                return (state, buttons, jolts)
                
            }
    }
    
    func run(_ input: Input) throws -> Output {
        try input.lazy.map(self.solve(_:)).reduce(0, +)
    }
    
    func solve(_ machine: Machine) throws -> Int {
        (1...machine.buttons.count).lazy.flatMap {
            machine.buttons.combinations(ofCount: $0)
        }.map { buttons in
            buttons.reduce(into: machine.state.map { _ in false }) { a, e in
                e.forEach { a[$0].toggle() }
            } == machine.state ? buttons.count : .max
        }.min()!
    }

}

class Day10B: Day10A {
    // I have a truly marvelous solution to this problem which this file is too narrow to contain
    override func solve(_ machine: Machine) throws -> Int {
        return 0
    }
}
