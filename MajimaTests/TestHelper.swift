import Foundation
import XCTest
@testable import Majima

func assertMerged<T: Equatable>(_ result: Result<T>, expected: T, file: String = #file, line: UInt = #line) {
    switch result {
    case .conflicted:
        XCTAssertFalse(true, "\(result)", file: #file, line: #line)
    case .merged(let obj):
        XCTAssertEqual(obj, expected, file: #file, line: #line)
    }
}

func assertMerged<T: Equatable>(_ result: Result<[T]>, expected: [T], file: String = #file, line: UInt = #line) {
    switch result {
    case .conflicted:
        XCTAssertFalse(true, "\(result)", file: #file, line: #line)
    case .merged(let obj):
        XCTAssertEqual(obj, expected, file: #file, line: #line)
    }
}

func assertConflicted<T>(_ result: Result<T>, file: String = #file, line: UInt = #line) {
    switch result {
    case .conflicted:
        XCTAssert(true, file: #file, line: #line)
    case .merged(let obj):
        XCTAssert(false, "\(obj)", file: #file, line: #line)
    }
}

func applyPatch<T>(base: [T], patch: [ArrayDiff<T>]) -> [T] {
    var array = base
    
    for diff in patch.reversed() {
        array = ThreeWayMerge.apply(base: array, diff: diff)
    }
    
    return array
}

func assertMerged<T>(_ result: Result<T>, file: String = #file, line: UInt = #line,  test: (T) -> ()) {
    switch result {
    case .merged(let x):
        test(x)
    case .conflicted:
        XCTAssert(false, "Unexpected .Conflicted", file: #file, line: #line)
    }
}
