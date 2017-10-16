import Foundation

enum ArrayDiff<T: Equatable>: Equatable {
    case insertion(Int, T)
    case deletion(Int)
    
    var position: Double {
        switch self {
        case .deletion(let i):
            return Double(i)
        case .insertion(let j, _):
            return Double(j) - 0.5
        }
    }
}

func ==<T>(d: ArrayDiff<T>, e: ArrayDiff<T>) -> Bool {
    switch (d, e) {
    case (.insertion(let p1, let r1), .insertion(let p2, let r2)):
        return p1 == p2 && r1 == r2
    case (.deletion(let r1), .deletion(let r2)):
        return r1 == r2
    default:
        return false
    }
}

class Graph<T: Equatable> {
    let original: [T]
    let new: [T]
    
    init(original: [T], new: [T]) {
        self.original = original
        self.new = new
    }
    
    /**
     Returns None if there is no edge from from to to.
     
     - (x:0, y:0) means origin
     - 0 <= x <= original.count should hold
     - 0 <= y <= new.count should hold
     */
    func cost(from: (x: Int, y: Int), to: (x: Int, y: Int)) -> UInt? {
        guard 0 <= from.x && to.x <= self.original.count && 0 <= from.y && to.y <= self.new.count else {
            return .none
        }
        
        guard to.x == from.x + 1 || to.y == from.y + 1 else {
            return .none
        }
        
        if to.x == from.x + 1 && to.y == from.y + 1 {
            if self.original[to.x - 1] == self.new[to.y - 1] {
                return 0
            } else {
                return .none
            }
        } else {
            return 1
        }
    }
    
    func enumeratePath(_ path: [ArrayDiff<T>], start: (x: Int, y: Int), candidates: inout [[ArrayDiff<T>]]) {
        if start.x == self.original.count && start.y == self.new.count {
            candidates.append(path)
        } else {
            if let _ = self.cost(from: start, to: (x: start.x + 1, y: start.y)) {
                self.enumeratePath(path + [.deletion(start.x)], start: (x: start.x + 1, y: start.y), candidates: &candidates)
            }
            if let _ = self.cost(from: start, to: (x: start.x + 1, y: start.y + 1)) {
                self.enumeratePath(path, start: (x: start.x + 1, y: start.y + 1), candidates: &candidates)
            }
            if let _ = self.cost(from: start, to: (x: start.x, y: start.y + 1)) {
                self.enumeratePath(path + [.insertion(start.x, self.new[start.y])], start: (x: start.x, y: start.y + 1), candidates: &candidates)
            }
        }
    }
}

class Diff {
    func diff<T: Equatable>(original: [T], new: [T]) -> [ArrayDiff<T>] {
        var paths: [[ArrayDiff<T>]] = []
        
        let graph = Graph<T>(original: original, new: new)
        graph.enumeratePath([], start: (x: 0, y: 0), candidates: &paths)
        
        return paths.min { $0.count < $1.count }!
    }
}

extension ThreeWayMerge {
    static func apply<T>(base: [T], diff: ArrayDiff<T>) -> [T] {
        var array = base
        
        switch diff {
        case .deletion(let i):
            array.remove(at: i)
        case .insertion(let i, let x):
            array.insert(x, at: i)
        }
        
        return array
    }
    
    static public func merge<T: Equatable>(base: [T], mine: [T], theirs: [T]) -> Result<[T]> {
        let diff = Diff()
        
        var myDiff: [ArrayDiff<T>] = diff.diff(original: base, new: mine).reversed()
        var theirDiff: [ArrayDiff<T>] = diff.diff(original: base, new: theirs).reversed()
        
        var result: [T] = base
        
        repeat {
            switch (myDiff.first, theirDiff.first) {
            case (.some(let d), .some(let e)) where d.position < e.position:
                result = self.apply(base: result, diff: e)
                theirDiff.removeFirst()
            case (.some(let d), .some(let e)) where d.position > e.position:
                result = self.apply(base: result, diff: d)
                myDiff.removeFirst()
            case (.some(let d), .some(let e)) where d == e:
                result = self.apply(base: result, diff: d)
                myDiff.removeFirst()
                theirDiff.removeFirst()
            case (.some(let d), .none):
                result = self.apply(base: result, diff: d)
                myDiff.removeFirst()
            case (.none, .some(let d)):
                result = self.apply(base: result, diff: d)
                theirDiff.removeFirst()
            default:
                return .conflicted
            }
        } while myDiff.count > 0 || theirDiff.count > 0
        
        return .merged(result)
    }
}
