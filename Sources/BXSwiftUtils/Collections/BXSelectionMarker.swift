//**********************************************************************************************************************
//
//  BXSelectionMarker.swift
//	Abstraction on top of Apple's deprecated NSMultipleValuesMarker
//  Copyright ©2016-2026 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import Foundation


//----------------------------------------------------------------------------------------------------------------------


// MARK: -

// Importing AppKit is needed for the NSBindingSelectionMarker class and the NSIsControllerMarker() function.
// For iOS, provide our own implementation of these.

#if os(macOS)
import AppKit
#endif


/// Cross-platform stand-in for AppKit's NSBindingSelectionMarker singletons.
///
/// AppKit's NSMultipleValuesMarker, NSNoSelectionMarker and NSNotApplicableMarker globals were deprecated in
/// macOS 11 in favor of the NSBindingSelectionMarker class. On macOS the properties below ARE those AppKit
/// markers - the very same singleton objects the old globals pointed to - so Cocoa Bindings and identity
/// comparisons keep behaving exactly as before. On iOS and tvOS, where AppKit doesn't exist, we supply our
/// own stand-ins.
///
/// Always compare markers by identity (===), never by value.

public enum BXSelectionMarker
{
	#if os(macOS)

	public static let multipleValues:AnyObject = NSBindingSelectionMarker.multipleValues
	public static let noSelection:AnyObject    = NSBindingSelectionMarker.noSelection
	public static let notApplicable:AnyObject  = NSBindingSelectionMarker.notApplicable

	#else

	public static let multipleValues:AnyObject = "NSMultipleValuesMarker" as AnyObject
	public static let noSelection:AnyObject    = "NSNoSelectionMarker" as AnyObject
	public static let notApplicable:AnyObject  = "NSNotApplicableMarker" as AnyObject

	#endif

	/// Returns true if the value is the marker for a selection with more than one distinct value

	public static func isMultipleValues(_ value:Any?) -> Bool
	{
		(value as AnyObject) === multipleValues
	}

	/// Returns true if the value is the marker for an empty selection

	public static func isNoSelection(_ value:Any?) -> Bool
	{
		(value as AnyObject) === noSelection
	}

	/// Returns true if the value is the marker for a property that doesn't apply to the selection

	public static func isNotApplicable(_ value:Any?) -> Bool
	{
		(value as AnyObject) === notApplicable
	}

	/// Returns true if the value is any of the three selection markers

	public static func isMarker(_ value:Any?) -> Bool
	{
		isMultipleValues(value) || isNoSelection(value) || isNotApplicable(value)
	}
}


//----------------------------------------------------------------------------------------------------------------------


// MARK: -

// On iOS and tvOS these AppKit names do not exist, so provide them here. They are kept as thin wrappers around
// BXSelectionMarker so that there is a single source of truth for the marker identities. New code should use
// BXSelectionMarker directly.

#if os(iOS) || os(tvOS)

public let NSNoSelectionMarker = BXSelectionMarker.noSelection
public let NSMultipleValuesMarker = BXSelectionMarker.multipleValues
public let NSNotApplicableMarker = BXSelectionMarker.notApplicable

public func NSIsControllerMarker(_ value:Any?) -> Bool
{
	BXSelectionMarker.isMarker(value)
}

public func NSIsMultipleValuesMarker(_ value:Any?) -> Bool
{
	BXSelectionMarker.isMultipleValues(value)
}

public func NSIsNoSelectionMarker(_ value:Any?) -> Bool
{
	BXSelectionMarker.isNoSelection(value)
}

public func NSIsNotApplicableMarker(_ value:Any?) -> Bool
{
	BXSelectionMarker.isNotApplicable(value)
}

#endif


//----------------------------------------------------------------------------------------------------------------------
