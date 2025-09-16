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

import AppKit

/// A wrapper around an NSDraggingInfo providing some conveniences
public class AUIDragInfo {
	init(_ dragInfo: any NSDraggingInfo) {
		self.dragInfo = dragInfo
	}

	/// The wrapped drag info
	public let dragInfo: any NSDraggingInfo

	/// Returns the first file in the drag info
	public func file() -> URL? {
		self.files().first
	}

	/// Returns all the files in the drag info
	public func files() -> [URL] {
		let pb = self.dragInfo.draggingPasteboard
		guard let objs = pb.readObjects(forClasses: [NSURL.self], options: nil) as? [NSURL] else {
			return []
		}
		return objs.compactMap { $0 as URL }
	}
}
