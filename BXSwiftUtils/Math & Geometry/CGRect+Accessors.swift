//**********************************************************************************************************************
//
//  CGRect+FMExtensions.swift
//	Adds convenience methods
//  Copyright ©2016-2018 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import Foundation
import CoreGraphics


//----------------------------------------------------------------------------------------------------------------------


/// This extension adds convenience accessors to NSRect

public extension CGRect
{
	/// Returns the center point of a CGRect
	
	var center: CGPoint
	{
		return CGPoint( x:self.midX, y:self.midY )
	}

	/// Returns the left point of a CGRect
	
	var left: CGPoint
	{
		return CGPoint( x:self.minX, y:self.midY )
	}

	/// Returns the bottom point of a CGRect
	
	var right: CGPoint
	{
		return CGPoint( x:self.maxX, y:self.midY )
	}

	/// Returns the top point of a CGRect
	
	var top: CGPoint
	{
		return CGPoint( x:self.midX, y:self.maxY )
	}

	/// Returns the bottom point of a CGRect
	
	var bottom: CGPoint
	{
		return CGPoint( x:self.midX, y:self.minY )
	}

	/// Returns the top left point of a CGRect
	
	var topLeft: CGPoint
	{
		return CGPoint( x:self.minX, y:self.maxY )
	}

	/// Returns the top right point of a CGRect
	
	var topRight: CGPoint
	{
		return CGPoint( x:self.maxX, y:self.maxY )
	}

	/// Returns the bottom left point of a CGRect
	
	var bottomLeft: CGPoint
	{
		return CGPoint( x:self.minX, y:self.minY )
	}

	/// Returns the bottom right point of a CGRect
	
	var bottomRight: CGPoint
	{
		return CGPoint( x:self.maxX, y:self.minY )
	}

	/// Returns the length of the shorter edge
	
	var shorterEdge: CGFloat
	{
		return min( self.width, self.height )
	}
	
	/// Returns the length of the longer edge
	
	var longerEdge: CGFloat
	{
		return max( self.width, self.height )
	}
	
	/// Returns the length of the diagonal
	
	var diagonal: CGFloat
	{
		let w = self.width
		let h = self.height
		return sqrt(w*w + h*h)
	}
	
	/// Scales a rectangle so that its longer edge has the specified length. This preserves the aspect ratio of the rect.
	/// - parameter maxEdge: The length of the longer edge after scaling
	/// - returns: The scaled CGRect
	
	func scale(to maxEdge:CGFloat) -> CGRect
	{
		let fx = maxEdge / self.width
		let fy = maxEdge / self.height
		let f = min(fx,fy)
		
		var rect = self
		rect.origin.x *= f		// Not sure if we should
		rect.origin.y *= f		// scale the origin too?
		rect.size.width *= f
		rect.size.height *= f
		return rect
	}
	
}


//----------------------------------------------------------------------------------------------------------------------
