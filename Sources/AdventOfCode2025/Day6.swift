import Foundation
import Algorithms

class Day6A: DayCommand {
    typealias Input = [(operator: Operator, arguments: [Int])]
    typealias Output = Int
    
    enum Operator: String {
        case mul = "*"
        case sum = "+"
        
        func apply(_ lhs: Int, _ rhs: Int) -> Int {
            switch self {
            case .mul: lhs * rhs
            case .sum: lhs + rhs
            }
        }
    }
    
    required init() { /**/ }

    func parseInput(_ input: String) throws -> Input {
        let lines = input.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        let numbers = try lines.dropLast().map { line in
            try line.components(separatedBy: .whitespaces)
                .filter { !$0.isEmpty }
                .map { try Int($0).unwrapOr(throw: "invalid input \($0) in \(line)") }
        }
        
        guard let lastLine = lines.last, !numbers.isEmpty else { throw "invalid input \(lines)" }
        
        let operators = try lastLine.components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
            .map { try Operator(rawValue: $0).unwrapOr(throw: "invalid input \($0) in \(lastLine)") }
        
        return Array(zip(operators, numbers.transposed())).map { $0 }
    }
    
    func run(_ input: Input) throws -> Output {
        return input.lazy.map { op, args in args.dropFirst().reduce(args.first!) { op.apply($0, $1) } }.reduce(0, +)
    }
}

class Day6B: Day6A {
    override func parseInput(_ input: String) throws -> Day6A.Input {
        let lines = input.split(separator: "\n", omittingEmptySubsequences: true)
        
        guard let lastLine = lines.last, lines.count > 1 else { throw "invalid input \(input)" }
        let operators: [(op: Operator, range: Range<Int>)] = try lastLine.matches(of: /(?<operator>[*+])\s+/)
            .map { match in
                let op = try Operator(rawValue: String(match.output.operator))
                    .unwrapOr(throw: "invalid input \(lastLine)")
                let lowerBound = lastLine.distance(from: lastLine.startIndex, to: match.range.lowerBound)
                let upperBound = lastLine.distance(from: lastLine.startIndex, to: match.range.upperBound)
                return (op, lowerBound..<upperBound)
            }
        
        let columns = try operators.map { op, range in
            let numbers: [Int] = try range.compactMap { offset in
                let characters: [Int] = try lines.lazy.dropLast()
                    .map { $0[$0.index($0.startIndex, offsetBy: offset)] }
                    .map { try Int($0.asciiValue.unwrapOr(throw: "Invalid input \($0) at \(offset)")) }
                    .filter { (0x30..<0x3A).contains($0) /*0-9*/ }
                    .map { $0 - 0x30 /*0*/ }
                
                return characters.isEmpty ? nil : characters.reduce(0) { $0 * 10 + $1 }
            }
            return (op, numbers)
        }
        
        return columns
    }
    
    override func run(_ input: Input) throws -> Output {
        return try super.run(input)
    }
}

private extension Collection where Element: Collection {
    func transposed() -> [[Element.Element]] {
        guard let firstRow = self.first else { return [] }
        return (0..<firstRow.count).map { columnIndex in
            self.compactMap { row in
                row.dropFirst(columnIndex).first
            }
        }
    }
}
