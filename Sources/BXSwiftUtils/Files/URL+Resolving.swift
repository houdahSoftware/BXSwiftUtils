//**********************************************************************************************************************
//
//  URL+Resolving.swift
//	Convenience methods for working with AliasData
//  Copyright ©2018 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import Foundation
import Darwin


//----------------------------------------------------------------------------------------------------------------------


// MARK: -

public extension URL
{
	/// Creates a URL for the AliasRecord contained in the given Data
	///
	/// Warning: This function doesn't yield the expected result yet - still in development!
	/// - parameter aliasData: Data containing an AliasRecord
	/// - returns: The URL that aliasData was pointing to

	static func resolving(aliasData:Data) throws -> URL?
	{
		#if os (iOS) || os(tvOS)

		// Since iOS doesn't support the CFURLCreateBookmarkDataFromAliasRecord function, we first write
		// the aliasData to a temporary file, which will be deleted after we are done using it.

		let folder = NSTemporaryDirectory()
		let tmpName = UUID().uuidString
		let tmpPath = "\(folder)/\(tmpName).alias"
		let tmpURL = URL(fileURLWithPath:tmpPath)

		try aliasData.write(to:tmpURL)

		defer
		{
			DispatchQueue.main.async { try? FileManager.default.removeItem(at:tmpURL) }
		}

		// Make sure that the OS recognizes it as an alias file

//		var attrs:[UInt8] = [0x61,0x6C,0x69,0x73,0x4D,0x41,0x43,0x53,0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00]
//		let attrData = Data(buffer:UnsafeBufferPointer(start:&attrs, count:attrs.count))
		let attrs:[UInt8] = [0x61,0x6C,0x69,0x73,0x4D,0x41,0x43,0x53,0x80,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00]
		let attrData = Data(bytes:attrs)

		_ = tmpURL.withUnsafeFileSystemRepresentation
		{
			path in

			attrData.withUnsafeBytes
			{
				setxattr(path,"com.apple.FinderInfo", $0, attrData.count, 0,0)
			}
		}

		// Then resolve the aliasFile (on disk) to a URL

		return try URL(resolvingAliasFileAt:tmpURL, options:[.withoutUI,.withoutMounting])
		
		#else
		
		// On macOS we can convert to a bookmark and then resolve that. The conversion is performed by
		// CFURLCreateBookmarkDataFromAliasRecord, which is called through the _CFURLCreateBookmarkDataFromAliasRecord
		// helper below - see the comment there for why.

		if let bookmarkData = _CFURLCreateBookmarkDataFromAliasRecord(aliasData)
		{
			var isStale = false
			return try URL(resolvingBookmarkData:bookmarkData, options:[.withoutUI,.withoutMounting], relativeTo:nil, bookmarkDataIsStale:&isStale)
		}

		return nil

		#endif
	}

}


//----------------------------------------------------------------------------------------------------------------------


// MARK: -

#if os(macOS)

/// Signature of the C function CFDataRef CFURLCreateBookmarkDataFromAliasRecord(CFAllocatorRef,CFDataRef).
///
/// The Unmanaged<CFData>? return type mirrors the "Create Rule", i.e. the returned CFData is already retained
/// and ownership is transferred to us - hence the takeRetainedValue() below.

private typealias CFURLCreateBookmarkDataFromAliasRecordFunc = @convention(c) (CFAllocator?,CFData) -> Unmanaged<CFData>?


/// Converts the raw bytes of a Carbon AliasRecord to bookmark data.
///
/// CFURLCreateBookmarkDataFromAliasRecord is deprecated since macOS 11 and DELIBERATELY still used here - please do
/// not "fix" this, as that would break opening of legacy documents:
///
/// 1) There is no replacement. Every modern API (URL(resolvingAliasFileAt:), NSURL.bookmarkData(withContentsOf:),
///    CFURLCreateBookmarkDataFromFile) needs an alias FILE, while all we have here are the raw AliasRecord bytes
///    that old documents stored. This function is the only one that accepts them - and Apple's own deprecation
///    note explicitly sanctions this use: "This function should only be used to convert Carbon AliasRecords to
///    bookmark data".
///
/// 2) The usual trick of silencing the warning with @available(macOS,deprecated:11.0) doesn't work either, because
///    Swift only suppresses deprecation warnings inside declarations that are themselves deprecated. The annotation
///    would therefore cascade from here to FMMediaFileRef.subPathForLegacyFormat() and on to its Decodable
///    init(from:) - which would then warn at every single decoding site.
///
/// For this reason the function is not called directly, but looked up at runtime with dlsym - the same technique
/// that swift_demangle() in String+demangle.swift uses. Since the compiler never sees the deprecated declaration,
/// it cannot warn about it. Behavior is unchanged, we still end up in the exact same CoreFoundation function.
/// The tradeoff is that the call is no longer checked at compile time: should Apple ever remove the symbol, this
/// silently returns nil (legacy AliasRecords no longer resolve) instead of failing the build.
/// - parameter aliasData: Data containing an AliasRecord
/// - returns: The equivalent bookmark data, or nil if the conversion failed

private func _CFURLCreateBookmarkDataFromAliasRecord(_ aliasData:Data) -> Data?
{
	let handle = dlopen(nil,RTLD_NOW)

	guard let symbol = dlsym(handle,"CFURLCreateBookmarkDataFromAliasRecord") else { return nil }
	let function = unsafeBitCast(symbol, to:CFURLCreateBookmarkDataFromAliasRecordFunc.self)
	guard let bookmarkRef = function(kCFAllocatorDefault,aliasData as CFData) else { return nil }

	return bookmarkRef.takeRetainedValue() as Data
}

#endif


//----------------------------------------------------------------------------------------------------------------------
