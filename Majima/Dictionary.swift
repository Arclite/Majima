import Foundation

extension ThreeWayMerge {
    public static func merge<K, V: Equatable>(base: [K: V], mine: [K: V], theirs: [K: V]) -> Result<[K: V]> {
        var all_keys: Set<K> = Set()
        all_keys = all_keys.union(base.keys)
        all_keys = all_keys.union(mine.keys)
        all_keys = all_keys.union(theirs.keys)
        
        var object: [K: V] = [:]
        
        for key in all_keys {
            let b = base[key]
            let m = mine[key]
            let t = theirs[key]
            
            switch self.merge(base: b, mine: m, theirs: t) {
            case .merged(let x):
                object[key] = x
            case .conflicted:
                return .conflicted
            }
        }
        
        return .merged(object)
    }
}
