import Foundation
import Algorithms
import Collections
import simd

class Day9A: DayCommand {
    typealias Input = [Point]
    typealias Output = Int
    
    typealias Component = Int
    typealias Point = SIMD2<Component>

    required init() { /**/ }

    func parseInput(_ input: String) throws -> Input {
        let lines = input.split(omittingEmptySubsequences: true) { $0.isWhitespace }
        let points: [Point] = try lines.map { line in
            let components = line.split(separator: ",", omittingEmptySubsequences: true)
            guard
                components.count == 2,
                let x = Component(components[0]),
                let y = Component(components[1])
            else { throw "invalid line \(line)" }
            return Point(x, y)
        }
        return points
    }
    
    func run(_ input: Input) throws -> Output {
        input.combinations(ofCount: 2).lazy.map {
            let d = simd_abs($0[0] &- $0[1]) &+ Point(1, 1)
            return d.x * d.y
        }.max() ?? 0
    }
}

class Day9B: Day9A {
    override func run(_ input: Input) -> Output {
        let xs = input.map(\.x).uniqued().sorted()
        let ys = input.map(\.y).uniqued().sorted()
        
        let xIndex = Dictionary(uniqueKeysWithValues: xs.enumerated().map { ($0.element, $0.offset) })
        let yIndex = Dictionary(uniqueKeysWithValues: ys.enumerated().map { ($0.element, $0.offset) })
        
        let xMids: [Component] = xs.adjacentPairs().map { ($0 + $1) / 2 }
        let yMids: [Component] = ys.adjacentPairs().map { ($0 + $1) / 2 }
        
        let lines: [(Point, Point)] = Array(chain(input, CollectionOfOne(input.first!)).adjacentPairs())
        
        func pointInside(_ p: Point) -> Bool {
            lines.lazy.map { l, r in
                (((l.y > p.y) != (r.y > p.y)) && (p.x < (r.x - l.x) * (p.y - l.y) / (r.y - l.y) + l.x))
            }.reduce(into: false) { a, e in a = a != e }
        }
        
        let bad = yMids.map { y in xMids.map { x in pointInside(Point(x, y)) } }
        let zeroes = Array(repeating: 0, count: (bad.first?.count ?? 0) + 1)
        let prefix = bad.reduce(into: [zeroes]) { a, e in
            a.append(zip(a.last!, e.map { $0 ? 0 : 1 }.reductions(0, +)).map(+))
        }
        
        typealias RedPoint = (p: Point, i: (x: Int, y: Int))
        let redPoints: [RedPoint] = input.map { p in
            RedPoint(p: p, i: (xIndex[p.x]!, yIndex[p.y]!))
        }
        
        let maxArea = redPoints.combinations(ofCount: 2).reduce(into: 0) { a, e in
            let (l, r) = (e[0], e[1])
            let (x1, x2) = (min(l.i.x, r.i.x), max(l.i.x, r.i.x))
            let (y1, y2) = (min(l.i.y, r.i.y), max(l.i.y, r.i.y))
            
            if prefix[y2][x2] - prefix[y1][x2] - prefix[y2][x1] + prefix[y1][x1] == 0 {
                let d = simd_abs(r.p &- l.p) &+ Point(1, 1)
                a = max(a, d.x * d.y)
            }
        }
        
        return maxArea
    }
}

