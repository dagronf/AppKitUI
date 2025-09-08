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
import WebKit
import os.log

/// A very simple web page viewer
///
/// Note that for a sandboxed application you need to set `com.apple.security.network.client` in your
/// entitlements for the web view to display
///
/// Info: https://www.hackingwithswift.com/articles/112/the-ultimate-guide-to-wkwebview
@MainActor
public class AUIWebView: NSView {
	/// Create a web view and initialize it with a url
	convenience public init(url: URL? = nil) {
		self.init(frame: .zero)
		if let url {
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
				self?.loadURL(url)
			}
		}
	}

	/// Create a web view and initialize it with a url binding
	convenience public init(url: Bind<URL?>) {
		self.init(frame: .zero)
		self.url(url)
	}

	/// Create a simple web page and populate it with a raw HTML string
	/// - Parameter htmlString: The html string
	convenience public init(htmlString: String) {
		self.init(frame: .zero)
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
			self?.loadHTMLString(htmlString)
		}
	}

	public override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		self.setup()
	}

	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.setup()
	}

	deinit {
		os_log("deinit: AUIWebView", log: logger, type: .debug)
	}

	// private

	var url: URL? { self.webView.url }

	private let webView = WKWebView()
	private var estimatedProgress: Bind<Double>?
	private var title: Bind<String>?
	private var pageURL: Bind<URL?>?
	private var isLoading: Bind<Bool>?

	private var disableNavigation = false

	private var didStartHandler: ((URL) -> Void)?
	private var decidePolicyHandler: ((WKNavigationAction) -> WKNavigationActionPolicy)?
	private var didFinishHandler: ((URL) -> Void)?
	private var didFailLoadingHandler: ((URL?, Error) -> Void)?
}

@MainActor
private extension AUIWebView {
	func setup() {
		self.translatesAutoresizingMaskIntoConstraints = false
		self.webView.translatesAutoresizingMaskIntoConstraints = false
		self.webView.navigationDelegate = self
		self.content(fill: webView)
	}

	func loadURL(_ url: URL?) {
		assert(Thread.isMainThread)
		if let url {
			let request = URLRequest(url: url)
			let aa = self.webView.load(request)
			Swift.print(aa)
		}
		else {
			self.showBlankPage()
		}
	}

	func loadHTMLString(_ htmlString: String) {
		assert(Thread.isMainThread)
		self.webView.loadHTMLString(htmlString, baseURL: nil)
	}

	func disableNavigationLinks() {
		let disableLinksJS = "document.querySelectorAll('a').forEach(a => { a.onclick = e => e.preventDefault(); a.style.pointerEvents = 'none'; });"
		self.webView.evaluateJavaScript(disableLinksJS, completionHandler: nil)
	}

	func showBlankPage() {
		let emptyHtmlString = "<html><head></head><body></body></html>"
		self.webView.loadHTMLString(emptyHtmlString, baseURL: nil)
	}
}

// MARK: - Modifiers

@MainActor
public extension AUIWebView {
	/// Disabled all user navigation from the loaded view
	///
	/// Injects javascript at the end of the loading that disables any links
	@discardableResult
	func disableUserNavigation() -> Self {
		self.disableNavigation = true
		return self
	}
}

// MARK: - Actions

@MainActor
public extension AUIWebView {
	/// Set a block to csll when a web page starts loading
	/// - Parameter block: The block, passing the url that is to be loaded
	/// - Returns: self
	@discardableResult
	func didStartLoading(_ block: @escaping (URL) -> Void) -> Self {
		self.didStartHandler = block
		return self
	}

	/// Call a block to ask for permission to navigate to new content based on the specified preferences and action information.
	/// - Parameter block: The block
	/// - Returns: self
	///
	/// Note that this is available only for macOS 10.15 onwards.
	/// It will **not** get called for earlier macOS versions
	///
	/// See [webview(_:decidepolicyfor:preferences:decisionhandler:)](https://developer.apple.com/documentation/webkit/wknavigationdelegate/webview(_:decidepolicyfor:preferences:decisionhandler:)) for more info
	@available(macOS 10.15, *)
	@discardableResult
	func shouldDecidePolicy(_ block: @escaping (WKNavigationAction) -> WKNavigationActionPolicy) -> Self {
		self.decidePolicyHandler = block
		return self
	}

	/// Set a block to csll when a web page finishes loading
	/// - Parameter block: The block, passing the loaded url
	/// - Returns: self
	@discardableResult
	func didFinishLoading(_ block: @escaping (URL) -> Void) -> Self {
		self.didFinishHandler = block
		return self
	}

	/// Set a block to csll when a web page fails to load
	/// - Parameter block: The block, passing the requested url and the error.
	/// - Returns: self
	@discardableResult
	func didFailLoading(_ block: @escaping (URL?, Error) -> Void) -> Self {
		self.didFailLoadingHandler = block
		return self
	}
}

// MARK: - Bindings

@MainActor
public extension AUIWebView {
	/// The URL to be loaded
	/// - Parameter url: The url
	/// - Returns: self
	@discardableResult
	func url(_ url: Bind<URL?>) -> Self {
		self.pageURL = url
		url.register(self) { @MainActor [weak self] newURL in
			self?.loadURL(newURL)
		}

		// We need to call the 'loadURL' AFTER the control has been set up fully,
		// or else the 'isLoaded', 'estimatedTime' observers may not be installed when the loading starts
		// Delay until the next main thread cycle
		DispatchQueue.main.async { [weak self] in
			self?.loadURL(url.wrappedValue)
		}

		return self
	}

	/// Retrieve the loading state for the web view
	/// - Parameter isLoading: The loading binding
	/// - Returns: self
	@discardableResult
	func isLoading(_ isLoading: Bind<Bool>) -> Self {
		self.isLoading = isLoading
		self.webView.addObserver(self, forKeyPath: #keyPath(WKWebView.loading), options: .new, context: nil)
		return self
	}

	/// The title for the loaded page
	/// - Parameter title: Binding for the title
	/// - Returns: self
	@discardableResult
	func title(_ title: Bind<String>) -> Self {
		self.title = title
		self.webView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
		return self
	}

	/// Binds to the loading progress state
	/// - Parameter progress: The estimated loading state (0.0 ... 1.0)
	/// - Returns: self
	func estimatedProgress(_ progress: Bind<Double>) -> Self {
		self.estimatedProgress = progress
		self.webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
		return self
	}
}

@MainActor
extension AUIWebView {

}

@MainActor
extension AUIWebView {
	override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if keyPath == "estimatedProgress" {
			self.estimatedProgress?.wrappedValue = self.webView.estimatedProgress
		}
		else if keyPath == "title" {
			self.title?.wrappedValue = self.webView.title ?? ""
		}
		else if keyPath == "loading" {
			self.isLoading?.wrappedValue = self.webView.isLoading
		}
	}
}

// MARK: - Delegate callbacks

@MainActor
extension AUIWebView: WKNavigationDelegate {
	/// Tells the delegate that the web view has started to receive content for the main frame.
	public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
		if let url = webView.url {
			self.pageURL?.wrappedValue = url
			if let callback = self.didStartHandler {
				callback(url)
			}
		}
	}

	public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
		if let decidePolicyHandler {
			let policy = decidePolicyHandler(navigationAction)
			decisionHandler(policy)
			return
		}
		decisionHandler(.allow)
	}

	public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error) {
		self.didFailLoadingHandler?(self.pageURL?.wrappedValue, error)
	}

	public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
		self.didFailLoadingHandler?(self.pageURL?.wrappedValue, error)
	}

	public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		guard let url else {
			return
		}

		if self.disableNavigation {
			self.disableNavigationLinks()
		}

		if let callback = self.didFinishHandler {
			callback(url)
		}
	}
}

// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("default") {
	let estimated = Bind(0.0) { newValue in
		Swift.print("estimated is now \(newValue)")
	}
	let title = Bind("") { newValue in
		Swift.print("title is now \(newValue)")
	}
	AUIWebView(url: URL(string: "https://github.com/dagronf/AppKitUI")!)
		//.disableUserNavigation()
		.estimatedProgress(estimated)
		.title(title)
		.didStartLoading { loadingURL in
			Swift.print("Started loading: \(loadingURL)")
		}
		.didFinishLoading { loadedURL in
			Swift.print("Finished loading: \(loadedURL)")
		}
}

#endif
