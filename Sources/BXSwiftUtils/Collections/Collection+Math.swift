//
//  Collection+Math.swift
//  BXSwiftUtils
//
//  Created by Peter Baumgartner on 21.11.23
//  Copyright ©2023 IMAGINE GbR. All rights reserved.
//


import Foundation


extension Collection where Element:AdditiveArithmetic
{
    /// The sum of the elements in this Collection
    ///
    /// Constrained to AdditiveArithmetic rather than to FloatingPoint, so that collections of Int sum as
    /// readily as collections of Double. AdditiveArithmetic supplies the .zero this needs as a seed.

    public func sum() -> Element
    {
		self.reduce(.zero,+)
    }
}


extension Collection where Element:FloatingPoint
{
    /// The average of the elements in this Collection
    ///
    /// Stays on FloatingPoint, because dividing by the element count requires a type that can be built from
    /// an Int and divided - neither of which AdditiveArithmetic provides.

    public func average() -> Element
    {
		let n = Element.init(count) 
		return self.sum() / n
    }
    
    
}
