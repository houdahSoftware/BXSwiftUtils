//
//  Collection+MathTests.swift
//  BXSwiftUtils
//
//  Copyright ©2026 IMAGINE GbR. All rights reserved.
//


import XCTest
@testable import BXSwiftUtils


class Collection_MathTests : XCTestCase
{
	func testSumOfDoubles()
	{
		XCTAssertEqual([1.0, 2.0, 3.5].sum(), 6.5)
	}

	/// sum() is constrained to AdditiveArithmetic rather than FloatingPoint, so integer collections work too.

	func testSumOfIntegers()
	{
		XCTAssertEqual([1, 2, 3].sum(), 6)
		XCTAssertEqual([-5, 5].sum(), 0)
	}

	/// The seed is .zero rather than a literal, which is what makes the wider constraint possible.

	func testSumOfEmptyCollection()
	{
		XCTAssertEqual([Double]().sum(), 0.0)
		XCTAssertEqual([Int]().sum(), 0)
	}

	func testSumOfSlice()
	{
		XCTAssertEqual([1, 2, 3, 4].dropFirst().sum(), 9)
	}

	func testAverage()
	{
		XCTAssertEqual([1.0, 2.0, 3.0].average(), 2.0)
		XCTAssertEqual([2.0, 4.0].average(), 3.0)
	}

	/// average() divides by the count, so an empty collection produces a NaN rather than trapping.

	func testAverageOfEmptyCollection()
	{
		XCTAssertTrue([Double]().average().isNaN)
	}
}
