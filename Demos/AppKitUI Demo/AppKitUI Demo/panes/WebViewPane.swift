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
import AppKitUI
import Security

class WebViewPane: Pane {
	override func title() -> String { "Web View" }
	@MainActor
	override func make(model: Model) -> NSView {
		let urlString = Bind("https://github.com/dagronf/AppKitUI")
		let url = Bind<URL?>(URL(string: "https://github.com/dagronf/AppKitUI"))
		let pageTitle = Bind("")
		let isLoading = Bind(false)
		let estimatedProgress = Bind(0.0)

		if hasNetworkClientEntitlement() == false {
			return AUIContentUnavailableView(title: "Missing network client entitlement")
		}
		else {
			return VStack(spacing: 0) {
				NSTextField(content: urlString)
					.bezelStyle(.roundedBezel)
					.onEndEditing { newUrlString in
						// We only want to start loading when the user commits on the field
						// If we used .onChanged here it would try to load a new page for each keystroke
						url.wrappedValue = URL(string: newUrlString)
					}
					.huggingPriority(.defaultLow, for: .horizontal)
					.padding(8)

				NSProgressIndicator()
					.range(0.0 ... 1.0)
					.isHidden(isLoading.toggled())
					.isIndeterminite(false)
					.value(estimatedProgress)
					.huggingPriority(.defaultLow, for: .horizontal)

				AUIWebView(url: url)
					.title(pageTitle)
					.isLoading(isLoading)
					.estimatedProgress(estimatedProgress)
					.didStartLoading { loadingURL in
						model.log("Started loading: \(loadingURL)")
						urlString.wrappedValue = loadingURL.absoluteString
					}
					.didFinishLoading { loadedURL in
						model.log("Finished loading: \(loadedURL)")
					}
					.didFailLoading { url, error in
						model.log("Failed loading URL: \(String(describing: url)) - error: \(error)")
					}
			}
			.detachesHiddenViews(true)
			.onChange(isLoading) { newValue in
				model.log(">> isLoading is now '\(newValue)'")
			}
			.onChange(pageTitle) { newValue in
				model.log(">> Page title is now '\(newValue)'")
			}
		}
	}
}

private func hasNetworkClientEntitlement() -> Bool {
	 guard let task = SecTaskCreateFromSelf(nil) else { return false }
	 let value = SecTaskCopyValueForEntitlement(
		task,
		"com.apple.security.network.client" as CFString,
		nil
	 )
	 // CFBoolean bridges to NSNumber/Bool; handle both safely
	 if let b = value as? Bool { return b }
	 if let n = value as? NSNumber { return n.boolValue }
	 return false
}

#if DEBUG
@available(macOS 14, *)
#Preview("Basic") {
	WebViewPane().make(model: Model())
		.frame(width: 640, height: 480)
}
#endif
