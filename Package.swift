// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(

    name: "BXSwiftUtils",
    defaultLocalization: "en",
    
    platforms:
    [
		.macOS(.v10_11),
		.iOS(.v11)
    ],
    
	// Products define the executables and libraries a package produces, and make them visible to other packages
        
    products:
    [
        .library(name:"BXSwiftUtils", targets:["BXSwiftUtils", "BXSwiftUtilsObjC"]),
    ],
    
	// Dependencies declare other packages that this package depends on
	
    dependencies:
    [
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    
	// Targets are the basic building blocks of a package. A target can define a module or a test suite.
	// Targets can depend on other targets in this package, and on products in packages this package depends on.

    targets:
    [
        .target(name:"BXSwiftUtilsObjC", dependencies:[]),
        .target(name:"BXSwiftUtils", dependencies:["BXSwiftUtilsObjC"]),
//		.testTarget( name:"BXMediaBrowserTests", dependencies:["BXMediaBrowser"]),
    ]
)
