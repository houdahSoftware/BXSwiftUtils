//**********************************************************************************************************************
//
//  IsAboutEqual.swift
//	Approximate equality for floating point values and the CoreGraphics types built from them
//  Copyright ©2026 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import Foundation
import CoreGraphics


//----------------------------------------------------------------------------------------------------------------------


/// Returns true if two values are equal to within `epsilon`.
///
/// Any value that has travelled through a division cannot be compared with `==`, so this is the comparison to reach
/// for whenever a computed number is checked against an expected one.
///
/// NOTE the difference from the neighbouring `Double.isEqual(_:_:precision:)`, which looks similar and is not the
/// same function:
///
/// - Infinities. `isAboutEqual` treats two infinities of the SAME SIGN as equal; `isEqual` reports any infinity as
///   unequal to everything. Both are defensible - an infinite measurement is usually a fault, but a computation that
///   is EXPECTED to overflow should still be able to assert that it did - so pick according to whether an infinity is
///   a legitimate answer in the case at hand.
/// - NaN is never equal to anything here, not even to itself. That is deliberate: a caller that accidentally produces
///   NaN gets a loud failure rather than a comparison that happens to be false for the wrong reason.
/// - The tolerance is inclusive (`<=`) and defaults to 1e-9, where `isEqual` is exclusive and defaults to 0.001.
///
/// Callers are encouraged to pass an explicit `epsilon` chosen for the arithmetic involved rather than relying on the
/// default, so that the magnitude is a stated decision.

public func isAboutEqual(_ value1:Double,_ value2:Double, epsilon:Double = 1e-9) -> Bool
{
	guard !value1.isNaN && !value2.isNaN else { return false }

	// Infinities only match their own sign, because abs(inf-inf) is NaN and would compare false below

	if value1.isInfinite || value2.isInfinite { return value1 == value2 }

	return abs(value1-value2) <= epsilon
}


//----------------------------------------------------------------------------------------------------------------------


/// Returns true if two points are equal to within `epsilon` in both coordinates

public func isAboutEqual(_ point1:CGPoint,_ point2:CGPoint, epsilon:Double = 1e-9) -> Bool
{
	isAboutEqual(point1.x, point2.x, epsilon:epsilon) &&
	isAboutEqual(point1.y, point2.y, epsilon:epsilon)
}


/// Returns true if two sizes are equal to within `epsilon` in both dimensions

public func isAboutEqual(_ size1:CGSize,_ size2:CGSize, epsilon:Double = 1e-9) -> Bool
{
	isAboutEqual(size1.width, size2.width, epsilon:epsilon) &&
	isAboutEqual(size1.height, size2.height, epsilon:epsilon)
}


/// Returns true if two rects are equal to within `epsilon` in origin and size

public func isAboutEqual(_ rect1:CGRect,_ rect2:CGRect, epsilon:Double = 1e-9) -> Bool
{
	isAboutEqual(rect1.origin, rect2.origin, epsilon:epsilon) &&
	isAboutEqual(rect1.size, rect2.size, epsilon:epsilon)
}


//----------------------------------------------------------------------------------------------------------------------
