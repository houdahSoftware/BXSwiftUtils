//**********************************************************************************************************************
//
//  ProcessInfo+UnitTests.swift
//	Detects whether this process exists to host a unit test bundle
//  Copyright ©2026 Peter Baumgartner. All rights reserved.
//
//**********************************************************************************************************************


import Foundation


//----------------------------------------------------------------------------------------------------------------------


public extension ProcessInfo
{
	/// True when this process was launched to run unit tests, rather than by a user.
	///
	/// This matters most for an APP HOSTED test bundle, where the test runner launches the real application and
	/// injects the tests into it. Everything the app does at startup happens for real: reaching out to backends,
	/// asking the system for access to media libraries, and putting windows or alerts on screen. On a CI agent
	/// there is nobody to dismiss a modal alert, so a single one hangs the run until the step times out.
	///
	/// TWO signals are checked, because they become true at different TIMES. `XCTestConfigurationFilePath` is set
	/// in the environment before main() runs, so it is the only one that can be trusted during app launch. The
	/// class lookup only answers once the test bundle has actually been injected, which happens at a point that is
	/// an implementation detail of the runner - reliable during a test, not reliable while the app is starting up.
	/// Checking both means the answer is correct at either moment.
	///
	/// XCTest is present for Swift Testing suites too, since those still run inside an .xctest bundle.
	///
	/// The value is cached, so a caller on a hot path pays for the lookup once.
	
	static let isRunningUnitTests:Bool =
	{
		if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil { return true }
		
		return NSClassFromString("XCTestCase") != nil
	}()
}


//----------------------------------------------------------------------------------------------------------------------
