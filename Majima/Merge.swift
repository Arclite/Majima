import Foundation

public enum Result<T> {
    case merged(T)
    case conflicted
}

public class ThreeWayMerge {
    public static func merge<T: Equatable>(base: T, mine: T, theirs: T) -> Result<T> {
        if (theirs == mine) {
            return .merged(theirs)
        }
        
        if (base == mine) {
            return .merged(theirs)
        }
        
        if (base == theirs) {
            return .merged(mine)
        }
        
        return .conflicted
    }
    
    public static func merge<T: Equatable>(base: T?, mine: T?, theirs: T?) -> Result<T?> {
        if theirs == mine {
            return .merged(theirs)
        }
        
        if (base == mine) {
            return .merged(theirs)
        }
        
        if (base == theirs) {
            return .merged(mine)
        }
        
        return .conflicted
    }
}
