//
//  Diff.swift
//  WebNotificationsIOS
//
//  Created by kaku on 11/20/15.
//  Copyright © 2015 kaku. All rights reserved.
//

import Foundation

struct Diff<T> {
	let results: [DiffStep<T>]
	var insertions: [DiffStep<T>] {
		return results.filter({ $0.isInsertion }).sort { $0.idx < $1.idx }
	}
	var deletions: [DiffStep<T>] {
		return results.filter({ !$0.isInsertion }).sort { $0.idx > $1.idx }
	}
	func reversed() -> Diff<T> {
		let reversedResults = self.results.reverse().map { (result: DiffStep<T>) -> DiffStep<T> in
			switch result {
			case .Insert(let i, let j):
				return .Delete(i, j)
			case .Delete(let i, let j):
				return .Insert(i, j)
			}
		}
		return Diff<T>(results: reversedResults)
	}
}

func +<T> (left: DiffStep<T>, right: Diff<T>) -> Diff<T> {
	return Diff<T>(results: [left] + right.results)
}

enum DiffStep<T> : CustomDebugStringConvertible {
	case Insert(Int, T)
	case Delete(Int, T)
	var isInsertion: Bool {
		switch(self) {
		case .Insert:
			return true
		case .Delete:
			return false
		}
	}
	var debugDescription: String {
		switch(self) {
		case .Insert(let i, let j):
			return "+\(j)@\(i)"
		case .Delete(let i, let j):
			return "-\(j)@\(i)"
		}
	}
	var idx: Int {
		switch(self) {
		case .Insert(let i, _):
			return i
		case .Delete(let i, _):
			return i
		}
	}
	var value: T {
		switch(self) {
		case .Insert(let j):
			return j.1
		case .Delete(let j):
			return j.1
		}
	}
}

extension Array where Element: Equatable {

	/// Returns the sequence of ArrayDiffResults required to transform one array into another.
	func diff(other: [Element]) -> Diff<Element> {
		let table = MemoizedSequenceComparison.buildTable(self, other, self.count, other.count)
		return Array.diffFromIndices(table, self, other, self.count, other.count)
	}

	/// Walks back through the generated table to generate the diff.
	private static func diffFromIndices(table: [[Int]], _ x: [Element], _ y: [Element], _ iCount: Int, _ jCount: Int) -> Diff<Element> {

		var result = Diff<Element>(results: [])

		var i = iCount, j = jCount

		while i >= 0 && j >= 0 {
			if i == 0 && j > 0 {
				j--
				result = DiffStep.Insert(j, y[j]) + result
			} else if j == 0 && i > 0 {
				i--
				result = DiffStep.Delete(i, x[i]) + result
			} else if j > 0 && table[i][j] == table[i][j-1] {
				j--
				result = DiffStep.Insert(j, y[j]) + result
			} else if i > 0 && table[i][j] == table[i-1][j] {
				i--
				result = DiffStep.Delete(i, x[i]) + result
			} else {
				i--
				j--
			}
		}

		return result
	}
}

struct MemoizedSequenceComparison<T: Equatable> {
	static func buildTable(x: [T], _ y: [T], _ n: Int, _ m: Int) -> [[Int]] {
		var table = Array(count: n + 1, repeatedValue: Array(count: m + 1, repeatedValue: 0))
		for i in 0...n {
			for j in 0...m {
				if (i == 0 || j == 0) {
					table[i][j] = 0
				}
				else if x[i-1] == y[j-1] {
					table[i][j] = table[i-1][j-1] + 1
				} else {
					table[i][j] = max(table[i-1][j], table[i][j-1])
				}
			}
		}
		return table
	}
}

class DiffHelper {
	static func get(s1: String?, s2: String?) -> String {
		if (s1 == nil || s2 == nil) {
			return ""
		}
		if (s1?.characters.count <= 0 || s2?.characters.count <= 0) {
			return ""
		}

		let a = s1!.characters.split { $0 == "\n" || $0 == "\t" }.map(String.init)
		let b = s2!.characters.split { $0 == "\n" || $0 == "\t" }.map(String.init)
		let diff = a.diff(b)
		let printableDiff = diff.results.map({ $0.debugDescription }).joinWithSeparator("\n")
		return printableDiff
	}
}