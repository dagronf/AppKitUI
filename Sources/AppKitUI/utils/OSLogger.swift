//
//  Copyright © 2025 Darren Ford. All rights reserved.
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//  documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial
//  portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
//  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//
//import Foundation
//import os
//
//final class OSLogger: Sendable {
//	private let _logger: OSLog
//	
//	init(subsystem: String, category: String) {
//		self._logger = OSLog(subsystem: subsystem, category: category)
//	}
//	
//	func loggingEnabled() -> Bool {
//		ProcessInfo.processInfo.environment["LOGGING_VERBOSE"] != nil
//	}
//	
//	func log(_ message: StaticString) {
//		os_log(message, log: self._logger)
//	}
//
//	func log(_ message: String, _ args: CVarArg...) {
//		NSLog(message, args)
//	}
//
//	@inlinable func debug(_ message: StaticString, _ args: CVarArg...) { log(.debug, message, args) }
//	@inlinable func info(_ message: StaticString, _ args: CVarArg...) { log(.info, message, args) }
//	@inlinable func error(_ message: StaticString, _ args: CVarArg...) { log(.error, message, args) }
//	@inlinable func fault(_ message: StaticString, _ args: CVarArg...) { log(.fault, message, args) }
//
//	func log(_ type: OSLogType, _ message: StaticString, _ args: CVarArg...) {
//		guard self.loggingEnabled() || type == .error else {
//			return
//		}
//		
//		// lack of splat means this mess:
//		switch args.count {
//		case 0:
//			os_log(message, log: self._logger, type: type)
//		case 1:
//			os_log(message, log: self._logger, type: type, args[0])
//		case 2:
//			os_log(message, log: self._logger, type: type, args[0], args[1])
//		case 3:
//			os_log(message, log: self._logger, type: type, args[0], args[1], args[2])
//		case 4:
//			os_log(message, log: self._logger, type: type, args[0], args[1], args[2], args[3])
//		case 5:
//			os_log(message, log: self._logger, type: type, args[0], args[1], args[2], args[3], args[4])
//		default:
//			os_log(message, log: self._logger, type: type, args[0], args[1], args[2], args[3], args[4], args[5])
//		}
//	}
//}
//
//let logger = OSLogger(subsystem: Bundle.main.bundleIdentifier!, category: "AppKitUI")
