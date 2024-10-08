//**********************************************************************************************************************
//
//  CGImage+ColorSpace.swift
//	Adds convenience methods
//  Copyright ©2022-2024 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


#if canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#endif

#if canImport(CoreGraphics)
import CoreGraphics
#endif


//----------------------------------------------------------------------------------------------------------------------


public extension CGImage
{

	/// If this image is not a 3-channel sRGB image, then convert it to sRGB colorspace.
	/// If it was already sRGB then the original image is returned.
	
	func convertTosRGB() -> CGImage?
	{
		self.convert(to:CGColorSpace.sRGB)
	}
	
	
	/// If this image is not a 3-channel DisplayP3 image, then convert it to DisplayP3 colorspace.
	/// If it was already DisplayP3 then the original image is returned.
	
	func convertToDisplayP3() -> CGImage?
	{
		self.convert(to:CGColorSpace.displayP3)
	}
	
	
	/// Converts this image to the RGB color space with the specified name
	
	func convert(to colorSpaceName:CFString) -> CGImage?
	{
		guard let colorSpace = self.colorSpace else { return nil }
		
		// If already in the correct color space then return the original image. This is the fast path.
		
		if let name = colorSpace.name, colorSpace.model == .rgb && name == colorSpaceName
		{
			return self
		}

		// Otherwise create a bitmap context with identical memory layout, but with the correct color space
		
		guard let newColorSpace = CGColorSpace(name:colorSpaceName) else
		{
			return nil
		}
		
		
		let w = self.width
		let h = self.height
		var bitsPerComponent = 8
        var bytesPerPixel = 4
        var bytesPerRow = bytesPerPixel * w
		let rect = CGRect(x:0, y:0, width:w, height:h)
		var bitmapInfo:UInt32 = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
		
		if colorSpaceName.isEDR
		{
			bitsPerComponent = 16
			bytesPerPixel = 8
			bytesPerRow = Int(1024 * ceil(Double(bytesPerPixel * w) / 1024))
//			bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder16Big.rawValue | CGBitmapInfo.floatComponents.rawValue
			bitmapInfo = kCGBitmapByteOrder16Host.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.floatComponents.rawValue
		}
		
//		kCGBitmapByteOrder16Host
//		kCGBitmapFloatComponents
//		kCGImagePropertyHasAlpha
//		kCGImageAlphaPremultipliedLast
		
		
		guard let context = CGContext(
			data:nil,
			width:w,
			height:h,
			bitsPerComponent:bitsPerComponent,
			bytesPerRow:bytesPerRow,
			space:newColorSpace,
			bitmapInfo:bitmapInfo) else { return nil }

		// Draw this image into the new bitmap and return the new image
		
		context.setAllowsAntialiasing(false)
		context.setShouldAntialias(false)
		context.draw(self, in:rect)
		return context.makeImage()
	}
	
}


//----------------------------------------------------------------------------------------------------------------------
