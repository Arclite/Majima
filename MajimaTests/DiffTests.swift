import Foundation
import Quick
@testable import Majima

struct DiffExample<T: Equatable> {
    let original: [T]
    let new: [T]
    let diff: [ArrayDiff<T>]
    let file: StaticString
    let line: UInt
}

func diffExample<T>(original: [T], new: [T], diff: [ArrayDiff<T>], file: StaticString = #file, line: UInt = #line) -> DiffExample<T> {
    return DiffExample<T>(original: original, new: new, diff: diff, file: file, line: line)
}

class DiffTest: QuickSpec {
    override func spec() {
        describe("Graph") {
            let graph = Graph(original: ["a","b","c"], new: ["a","c","x"])
            
            it("calculates cost") {
                XCTAssertEqual(0, graph.cost(from: (x: 0, y: 0), to: (x: 1, y: 1)))
                XCTAssertEqual(1, graph.cost(from: (x: 0, y: 0), to: (x: 0, y: 1)))
                XCTAssertEqual(0, graph.cost(from: (x: 2, y: 1), to: (x: 3, y: 2)))
                XCTAssertNil(graph.cost(from: (x: 1, y: 1), to: (x: 2, y: 2)))
            }
        }
        
        describe("Diff") {
            let examples = [
                diffExample(original: ["1","2","3"], new: ["1","2","3"], diff: []),
                diffExample(original: ["1","2","3"], new: ["1","2"], diff: [.deletion(2)]),
                diffExample(original: ["1","2","3"], new: ["1","2","3","4"], diff: [.insertion(3, "4")]),
                diffExample(original: ["1","2"], new: ["0","2"], diff: [.deletion(0), .insertion(1, "0")]),
                diffExample(original: ["1","2","3"], new: ["2","1","3"], diff: [.deletion(0), .insertion(2, "1")]),
                diffExample(original: ["1","2","3"], new: ["2","3","4","5"], diff: [.deletion(0), .insertion(3, "4"), .insertion(3, "5")])
            ]
            
            it("calculates diff") {
                let diff = Diff()
                
                examples.forEach { example in
                    let d = diff.diff(original: example.original, new: example.new)
                    XCTAssertEqual(d, example.diff, file: example.file, line: example.line)
                    XCTAssertEqual(example.new, applyPatch(base: example.original, patch: example.diff))
                }
            }
        }
    }
}
