//**********************************************************************************************************************
//
//  String+Timecode.swift
//	Extension for displaying and parsing time codes
//  Copyright ©2018 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import Foundation


//----------------------------------------------------------------------------------------------------------------------


extension Double
{
	/// The placeholder returned instead of a timecode when the value cannot be represented.
	///
	/// Dashes follow the convention media players use for an unknown duration (QuickTime, the Music app, VLC and
	/// HTML5 players all show them when a duration is NaN or not yet known). They are deliberately NOT "0:00:00":
	/// a placeholder must not be mistakable for a real value, and a zero duration is a perfectly ordinary one.
	///
	/// The shape follows the format - same separators, same number of fraction digits - so the placeholder reads as
	/// a timecode that is simply not known. It cannot match the width of EVERY timecode, because the hours field is
	/// variable width (`%i`): "9:00:00.000" is one character shorter than "10:00:00.000". Two dashes are used for
	/// the hours, matching the two-digit case, rather than one dash that could be misread as the minus sign a
	/// negative duration now carries.
	
	public static func invalidTimecodeString(fps: Int = 1000) -> String
	{
		return fps > 100 ? "--:--:--.---" : "--:--:--.--"
	}
	
	/// The placeholder for the short form
	
	public static let invalidShortTimecodeString = "--:--:--"
	
	/// The largest magnitude that will be rendered as a timecode.
	///
	/// The hours field goes through `Int(_:)`, which TRAPS rather than saturating, and the value is divided by
	/// 3600 before it gets there. This ceiling sits many orders of magnitude below the point where that would
	/// actually overflow, which leaves no room for a rounding error to sneak past it - and 1e15 seconds is around
	/// 32 million years, so nothing a caller could legitimately mean is being excluded.
	
	public static let maximumTimecodeSeconds = 1.0e15
	
	
	/// Converts the number of seconds into a timecode string of format "HH:MM:SS.ff"
	///
	/// A value that cannot be represented - NaN, an infinity, or a magnitude beyond `maximumTimecodeSeconds` -
	/// yields `invalidTimecodeString(fps:)` rather than crashing. It used to crash: `Int(_:)` traps on a
	/// non-finite operand instead of saturating, so a NaN duration took the process down.
	///
	/// A negative value is formatted from its magnitude with a leading minus, e.g. "-0:00:05.500". Previously the
	/// sign leaked into the individual fields and produced unparseable output like "0:00:-5.-500".
	///
	/// The `isFinite` test is deliberately redundant: `abs(nan) <= x` is already false, since every comparison
	/// against NaN is, and an infinity exceeds any ceiling. It is kept because it states the intent - a mutation
	/// that removes it cannot be caught by a test, so only this note stops it being "simplified" away on the
	/// assumption that the magnitude check was doing that work by accident.
	
	public func timecodeString(fps: Int = 1000) -> String
	{
		guard self.isFinite, abs(self) <= Self.maximumTimecodeSeconds
		else { return Self.invalidTimecodeString(fps:fps) }
		
		let isNegative = self < 0.0
		var value = abs(self)
		
		let ff = Int(value.truncatingRemainder(dividingBy:1.0) * Double(fps))
		let SS = Int(value.truncatingRemainder(dividingBy:60.0))
		
		value -= Double(SS)
		value /= 60.0
		let MM = Int(value.truncatingRemainder(dividingBy:60.0))
		
		value -= Double(MM)
		value /= 60.0
		let HH = Int(value)
		
		let format = fps > 100 ? "%i:%02i:%02i.%03i" : "%i:%02i:%02i.%02i"
		let string = NSString(format:format as NSString,HH,MM,SS,ff) as String
		
		return isNegative ? "-" + string : string
	}


	/// Converts the number of seconds into a timecode string of format "HH:MM:SS"
	///
	/// Same guards as `timecodeString(fps:)`. Note that the magnitude is floored, so a negative value truncates
	/// TOWARDS zero - -5.5 is "-0:00:05" rather than "-0:00:06" - which is the usual reading for a signed duration.
	
	public func shortTimecodeString() -> String
	{
		guard self.isFinite, abs(self) <= Self.maximumTimecodeSeconds
		else { return Self.invalidShortTimecodeString }
		
		let isNegative = self < 0.0
		var value = floor(abs(self))
		
		let SS = Int(value.truncatingRemainder(dividingBy:60.0))
		
		value -= Double(SS)
		value /= 60.0
		let MM = Int(value.truncatingRemainder(dividingBy:60.0))
		
		value -= Double(MM)
		value /= 60.0
		let HH = Int(value)
		
		let string = NSString(format:"%i:%02i:%02i",HH,MM,SS) as String
		
		return isNegative ? "-" + string : string
	}
}


//----------------------------------------------------------------------------------------------------------------------


extension String
{
	/// Converts a timecode string of format "HH:MM:SS.sss" to the time in seconds (as a Double)
	
	public func timecodeValueInSeconds() -> Double
	{
		var value = 0.0
		var factor = 1.0
		let components = self.components(separatedBy:":").reversed()

		for component in components
		{
			if let v = Double(component)
			{
				value += factor * v
			}
			
			factor *= 60.0
		}
		
		return value
	}
}


//----------------------------------------------------------------------------------------------------------------------

