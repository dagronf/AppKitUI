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

import Foundation

// These functions allow previews in applications that support back to 10.13
// They are ignored if the target platform is 10.15 or later

// Add this file to any target that supports < 10.15 if you want to support Xcode previews

@backDeployed(before: macOS 10.15)
public func __designTimeString<A: Swift.ExpressibleByStringLiteral>(_: Swift.String, fallback: A) -> A {
	fallback
}
@backDeployed(before: macOS 10.15)
public func __designTimeFloat<A: Swift.ExpressibleByFloatLiteral>(_: Swift.String, fallback: A) -> A {
	fallback
}
@backDeployed(before: macOS 10.15)
public func __designTimeBoolean<A: Swift.ExpressibleByBooleanLiteral>(_: Swift.String, fallback: A) -> A {
	fallback
}
@backDeployed(before: macOS 10.15)
public func __designTimeInteger<A: Swift.ExpressibleByIntegerLiteral>(_: Swift.String, fallback: A) -> A {
	fallback
}
