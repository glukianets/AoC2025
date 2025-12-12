import Foundation
import Algorithms

class Day12A: DayCommand {
    typealias Output = Int
    typealias ShapeId = Int
    typealias Input = (shapes: [ShapeId: Shape], regions: [Region])
    typealias Region = (size: (x: Int, y: Int), shapes: [ShapeId: Int])

    struct Shape {
        let mask: UInt16
        
        init(description: some StringProtocol) throws {
            self.mask = try description.reduce(into: 0 as UInt16) { a, e in
                switch e {
                case "#":
                    a |= 1; fallthrough
                case ".":
                    a <<= 1
                case let c where c.isWhitespace:
                    break
                default:
                    throw "unrecognized symbol \(e)"
                }
            }
        }
    }

    required init() { /**/ }

    func parseInput(_ input: String) throws -> Input {
        let shapeRegex = /^(?<id>\d+):(?<mask>(?:\n[#.]{3}){3})\s*$/
        let regionRegex = /^(?<x>\d+)x(?<y>\d+):(?<shapes>(?:\s+\d+)+)\s*$/

        let pairs = input.split(separator: "\n\n")
        
        guard pairs.count > 1 else { throw "Invalid input \(input)" }
        
        let shapePairs: [(id: Int, shape: Shape)] = try pairs.dropLast().map {
            guard
                let match = $0.wholeMatch(of: shapeRegex),
                let id = Int(match.output.id),
                let shape = try? Shape(description: match.output.mask)
            else { throw "Invalid shape \($0)" }
            
            return (id, shape)
        }
        
        let shapes = try Dictionary(shapePairs) { l, _ in throw "Duplicate shape id \(l)" }
        
        let regions: [Region] = try pairs.last!.split(separator: "\n").map {
            guard
                let match = $0.wholeMatch(of: regionRegex),
                let x = Int(match.output.x),
                let y = Int(match.output.y)
            else { throw "Invalid region \($0)" }
            
            let shapeCounts: [(ShapeId, Int)] = try match.output.shapes.split(separator: " ")
                .map { try Int($0).unwrapOr(throw: "Invalid id \($0)") }
                .enumerated().map { $0 as (Int, Int) }
            
            let shapes = Dictionary<ShapeId, Int>(uniqueKeysWithValues: shapeCounts)

            return ((x, y), shapes)
        }
        
        return (shapes, regions)
    }
    
    func run(_ input: Input) throws -> Output {
        return 0
    }
}

class Day12B: Day12A {
    override func run(_ input: Input) throws -> Output {
        return 0
    }
}
