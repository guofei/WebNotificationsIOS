//
//  UrlHelperTests.swift
//  WebNotificationsIOS
//
//  Created by kaku hi on 9/10/17.
//  Copyright © 2017 kaku. All rights reserved.
//

import XCTest
@testable import WebChecker

class UrlHelperTests: XCTestCase {
    
  override func setUp() {
      super.setUp()
      // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
      // Put teardown code here. This method is called after the invocation of each test method in the class.
      super.tearDown()
  }

  func testExample() {
      // This is an example of a functional test case.
      // Use XCTAssert and related functions to verify your tests produce the correct results.
  }

  func testPerformanceExample() {
      // This is an example of a performance test case.
      self.measure {
          // Put the code you want to measure the time of here.
      }
  }

  func testGetURL() {
    let url1 = "a.com"
    let url1Result = "http://a.com"
    XCTAssertEqual(UrlHelper.getURL(url1)!, url1Result)
    XCTAssertEqual(UrlHelper.getURL(UrlHelper.getURL(url1))!, url1Result)

    let url2 = "https://a.com/?q1=こんにちは&q2=你好"
    let url2Result = "https://a.com/?q1=%E3%81%93%E3%82%93%E3%81%AB%E3%81%A1%E3%81%AF&q2=%E4%BD%A0%E5%A5%BD"
    XCTAssertEqual(UrlHelper.getURL(url2)!, url2Result)
    XCTAssertEqual(UrlHelper.getURL(UrlHelper.getURL(url2))!, url2Result)
  }
    
}
