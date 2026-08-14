//**********************************************************************************************************************
//
//  Date+Compare.swift
//	Adds compare operators to Date
//  Copyright ©2025 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import Foundation


//----------------------------------------------------------------------------------------------------------------------


public extension Date
{
	/// Checks if two Dates are almost the same
	
    static func isAlmostEqual(_ lhs:Date,_ rhs:Date, tolerance:TimeInterval = Self.dateComparisonTolerance) -> Bool
    {
        return abs(lhs.timeIntervalSince1970 - rhs.timeIntervalSince1970) < tolerance
    }
    
	static let dateComparisonTolerance:TimeInterval = 1.0
}


//----------------------------------------------------------------------------------------------------------------------


