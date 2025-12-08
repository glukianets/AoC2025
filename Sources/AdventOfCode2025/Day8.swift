import Foundation
import Algorithms
import Collections
import simd

class Day8A: DayCommand {
    typealias Input = [Point]
    typealias Output = Int
    
    typealias Component = Float
    typealias Point = SIMD3<Component>
    typealias Connection = (l: Point, r: Point, distance: Component)

    required init() { /**/ }

    func parseInput(_ input: String) throws -> Input {
        let lines = input.split(omittingEmptySubsequences: true) { $0.isWhitespace }
        let points: [Point] = try lines.map { line in
            let components = line.split(separator: ",", omittingEmptySubsequences: true)
            guard
                components.count == 3,
                let x = Component(components[0]),
                let y = Component(components[1]),
                let z = Component(components[2])
            else { throw "invalid line \(line)" }
            return Point(x, y, z)
        }
        return points
    }
    
    var colors: [Point: Int] = [:]
    var clusters: [Int: Set<Point>] = [:]

    func color(_ point: Point, with newColor: Int) throws {
        if let oldColor = colors.updateValue(newColor, forKey: point) {
            guard oldColor != newColor else { return }
            guard let oldCluster = clusters.removeValue(forKey: oldColor) else {
                throw "rogue point \(point) without a cluster"
            }
            for clusterPoint in oldCluster {
                colors[clusterPoint] = newColor
            }
            clusters[newColor, default: []].formUnion(oldCluster)
            
        } else {
            clusters[newColor, default: []].insert(point)
        }
    }
    
    func connect(_ input: Input) -> [Connection] {
        input.combinations(ofCount: 2)
            .map { Connection($0[0], $0[1], simd.distance($0[0], $0[1])) }
            .sorted { $0.distance < $1.distance }
    
    }
    
    func run(_ input: Input) throws -> Output {
        self.colors.removeAll()
        self.clusters.removeAll()
        let connections = self.connect(input)

        var lastColor = 0
        for connection in connections.prefix(1000) {
            let color = self.colors[connection.l] ?? self.colors[connection.r] ?? lastColor.advance(by: 1)
            try self.color(connection.l, with: color)
            try self.color(connection.r, with: color)
        }
        
        return self.clusters.values.map(\.count).sorted(by: >).prefix(3).reduce(1, *)
    }
}

class Day8B: Day8A {
    override func run(_ input: Input) throws -> Output {
        self.colors.removeAll()
        self.clusters.removeAll()
        let connections = self.connect(input)
        
        for (index, point) in input.indexed() {
            try color(point, with: index)
        }

        for connection in connections {
            try color(connection.r, with: colors[connection.l]!)
            if self.clusters.count == 1 {
                return Int(connection.l.x) * Int(connection.r.x)
            }
        }
        
        throw "Failed to connect graph entirely"
    }
}
