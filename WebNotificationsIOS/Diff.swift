//
//  Diff.swift
//  WebNotificationsIOS
//
//  Created by kaku on 11/20/15.
//  Copyright © 2015 kaku. All rights reserved.
//

import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}

struct Diff<T> {
  let results: [DiffStep<T>]
  var insertions: [DiffStep<T>] {
    return results.filter({ $0.isInsertion }).sorted { $0.idx < $1.idx }
  }
  var deletions: [DiffStep<T>] {
    return results.filter({ !$0.isInsertion }).sorted { $0.idx > $1.idx }
  }
  func reversed() -> Diff<T> {
    let reversedResults = self.results.reversed().map { (result: DiffStep<T>) -> DiffStep<T> in
      switch result {
      case .insert(let i, let j):
        return .delete(i, j)
      case .delete(let i, let j):
        return .insert(i, j)
      }
    }
    return Diff<T>(results: reversedResults)
  }
}

func +<T> (left: DiffStep<T>, right: Diff<T>) -> Diff<T> {
  return Diff<T>(results: [left] + right.results)
}

enum DiffStep<T> : CustomDebugStringConvertible {
  case insert(Int, T)
  case delete(Int, T)
  var isInsertion: Bool {
    switch(self) {
    case .insert:
      return true
    case .delete:
      return false
    }
  }
  var debugDescription: String {
    switch(self) {
    case .insert(let i, let j):
      return "+\(j)@\(i)"
    case .delete(let i, let j):
      return "-\(j)@\(i)"
    }
  }
  var toString: String {
    switch(self) {
    case .insert(_, let j):
      return "+\(j)"
    case .delete(_, let j):
      return "-\(j)"
    }
  }
  var idx: Int {
    switch(self) {
    case .insert(let i, _):
      return i
    case .delete(let i, _):
      return i
    }
  }
  var value: T {
    switch(self) {
    case .insert(let j):
      return j.1
    case .delete(let j):
      return j.1
    }
  }
}

extension Array where Element: Equatable {

  /// Returns the sequence of ArrayDiffResults required to transform one array into another.
  func diff(_ other: [Element]) -> Diff<Element> {
    let table = MemoizedSequenceComparison.buildTable(self, other, self.count, other.count)
    return Array.diffFromIndices(table, self, other, self.count, other.count)
  }

  /// Walks back through the generated table to generate the diff.
  fileprivate static func diffFromIndices(_ table: [[Int]], _ x: [Element], _ y: [Element], _ iCount: Int, _ jCount: Int) -> Diff<Element> {

    var result = Diff<Element>(results: [])

    var i = iCount, j = jCount

    while i >= 0 && j >= 0 {
      if i == 0 && j > 0 {
        j -= 1
        result = DiffStep.insert(j, y[j]) + result
      } else if j == 0 && i > 0 {
        i -= 1
        result = DiffStep.delete(i, x[i]) + result
      } else if j > 0 && table[i][j] == table[i][j-1] {
        j -= 1
        result = DiffStep.insert(j, y[j]) + result
      } else if i > 0 && table[i][j] == table[i-1][j] {
        i -= 1
        result = DiffStep.delete(i, x[i]) + result
      } else {
        i -= 1
        j -= 1
      }
    }

    return result
  }
}

struct MemoizedSequenceComparison<T: Equatable> {
  static func buildTable(_ x: [T], _ y: [T], _ n: Int, _ m: Int) -> [[Int]] {
    var table = Array(repeating: Array(repeating: 0, count: m + 1), count: n + 1)
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
  static func get(_ origin: String?, newData: String?) -> String {
    if (origin == nil || newData == nil) {
      return ""
    }
    if (origin?.characters.count <= 0 || newData?.characters.count <= 0) {
      return ""
    }

    // just split by Line break
    let splitor = { (c: Character) -> Bool in
      if c == "\n" {
        return true
      } else if c == "\r" {
        return true
      } else if c == "\r\n" {
        return true
      } else {
        return false
      }
    }

    let maxSentenceLen = 100
    let splitSentence = " ,、，:：.。。；;！！!"
    let trans = { (sub: String.CharacterView) -> [String] in
      let s = String.init(sub)
      if s.characters.count > maxSentenceLen {
        // something like $99.99 will be splited
        return s.characters.split { splitSentence.characters.contains($0) }.map(String.init)
      } else {
        return [s]
      }
    }
    let a = origin!.characters.split(whereSeparator: splitor).map(trans).flatMap{$0}
    let b = newData!.characters.split(whereSeparator: splitor).map(trans).flatMap{$0}

    let diff = a.diff(b)
    let printableDiff = diff.results.map({ $0.toString }).joined(separator: "\n")
    return printableDiff
  }
}
