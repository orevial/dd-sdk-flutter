//
//  FlutterSdkAttibutesTests.swift
//  flutter_sdk_tests
//
//  Created by Jeff Ward on 12/20/21.
//

import XCTest
import Datadog

@testable import datadog_sdk

class FlutterSdkAttributesTests: XCTestCase {
  func testAttributes_SimpleValues_AreEncodedProperly() {
    let flutterTypes: [String: Any?] = [
      "intValue": NSNumber(value: 8),
      "doubleValue": NSNumber(value: 3.1415),
      "booleanValue": NSNumber(value: false),
      "stringValue": "String value",
      "nullValue": nil
    ]
    let encoded = castFlutterAttributesToSwift(flutterTypes)

    XCTAssertEqual(encoded["intValue"]?.value as? Int64, 8)
    XCTAssertEqual(encoded["doubleValue"]?.value as? Double, 3.1415)
    XCTAssertEqual(encoded["booleanValue"]?.value as? Bool, false)
    XCTAssertEqual(encoded["stringValue"]?.value as? String, "String value")
  }

  func testAttributes_NestedTypes_AreEncodedProperly() {
    let flutterTypes: [String: Any?] = [
      "arrayType": [ "My String Value", NSNumber(value: 32) ],
      "objectType": [
        "doubleValue": NSNumber(value: 3.1415),
        "booleanValue": NSNumber(value: true)
      ]
    ]
    let encoded = castFlutterAttributesToSwift(flutterTypes)

    // One level deep, values aren't encoded
    let array = encoded["arrayType"]?.value as? [Any]
    XCTAssertNotNil(array)
    XCTAssertEqual(array?[0] as? String, "My String Value")
    XCTAssertEqual(array?[1] as? Int64, 32)

    let object = encoded["objectType"]?.value as? [String: Any]
    XCTAssertNotNil(object)
    XCTAssertEqual(object?["doubleValue"] as? Double, 3.1415)
    XCTAssertEqual(object?["booleanValue"] as? Bool, true)
  }
}
