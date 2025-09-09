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
import os.log
import PDFKit

/// A PDF viewer component
@MainActor
public class AUIPDFView: NSView {

	/// Create a PDF view
	public convenience init() {
		self.init(frame: .zero)
	}

	/// Create a PDF view displaying a PDF
	public convenience init(fileURL: URL) {
		self.init(frame: .zero)
		self.fileURL(fileURL)
	}

	/// Create a PDF view displaying a PDF
	public convenience init(pdfData: Data) {
		self.init(frame: .zero)
		self.data(pdfData)
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
		os_log("deinit: AUIPDFView", log: logger, type: .debug)
	}

	private let pdfView = PDFView()
	private var pdfDocument: PDFDocument?
	private var scaling: Bind<Double>?
	private var range: ClosedRange<Double>?
}

@MainActor
extension AUIPDFView: @preconcurrency PDFViewDelegate {
	func setup() {
		self.wantsLayer = true
		self.translatesAutoresizingMaskIntoConstraints = false
		self.pdfView.delegate = self
		self.content(fill: self.pdfView)
	}

	public func pdfViewWillChangeScaleFactor(_ sender: PDFView, toScale scaler: CGFloat) -> CGFloat {
		let newValue = max(self.pdfView.minScaleFactor, min(self.pdfView.maxScaleFactor, scaler))
		self.scaling?.wrappedValue = newValue
		return newValue
	}
}

// MARK: - Modifiers

@MainActor
public extension AUIPDFView {
	/// Display the content of a pdf file
	/// - Parameter fileURL: The file url for the pdf to display
	/// - Returns: self
	@discardableResult
	func fileURL(_ fileURL: URL?) -> Self {
		guard let fileURL else {
			self.pdfDocument = nil
			self.pdfView.document = nil
			return self
		}

		self.pdfDocument = PDFDocument(url: fileURL)
		self.pdfView.document = self.pdfDocument

		if let range {
			self.pdfView.minScaleFactor = range.lowerBound
			self.pdfView.maxScaleFactor = range.upperBound
		}
		return self
	}

	/// Display the content of a pdf
	/// - Parameter fileURL: The data for the pdf to display
	/// - Returns: self
	@discardableResult
	func data(_ pdfData: Data) -> Self {
		self.pdfDocument = PDFDocument(data: pdfData)
		self.pdfView.document = self.pdfDocument
		if let range {
			self.pdfView.minScaleFactor = range.lowerBound
			self.pdfView.maxScaleFactor = range.upperBound
		}
		return self
	}
}

// MARK: - Bindings

@MainActor
public extension AUIPDFView {
	/// The file URL
	/// - Parameter fileURL: The file URL for the document to display
	/// - Returns: self
	@discardableResult
	func fileURL(_ fileURL: Bind<URL?>) -> Self {
		fileURL.register(self) { @MainActor [weak self] newValue in
			self?.fileURL(newValue)
		}

		self.fileURL(fileURL.wrappedValue)
		return self
	}

	/// Bind the scaling factor for the view
	/// - Parameters:
	///   - factor: The view scale
	///   - range: The scaling range
	/// - Returns: self
	@discardableResult
	func scaleFactor(_ factor: Bind<Double>, range: ClosedRange<Double>) -> Self {
		self.scaling = factor

		self.range = range
		self.pdfView.minScaleFactor = range.lowerBound
		self.pdfView.maxScaleFactor = range.upperBound

		factor.register(self) { @MainActor [weak self] newScaleFactor in
			self?.pdfView.scaleFactor = newScaleFactor
		}

		self.pdfView.scaleFactor = factor.wrappedValue
		return self
	}
}

// MARK: - Previews

#if DEBUG

@available(macOS 14, *)
#Preview("default") {
	let scale = Bind(1.0)
	VStack {
		NSGridView {
			NSGridView.Row {
				NSTextField(label: "scale:")
				NSSlider(scale, range: 0.25 ... 4)
			}
			.rowAlignment(.firstBaseline)
		}

		AUIPDFView(pdfData: makeDummyPDF())
			.scaleFactor(scale, range: 0.25 ... 4)
	}
	.padding(top: 40, left: 20, bottom: 20, right: 20)
}

private func makeDummyPDF() -> Data {
	var pageRect = CGRect(x: 0, y: 0, width: 595.2, height: 841.8)

	let data = CFDataCreateMutable(nil, 0)!
	let pdfConsumer = CGDataConsumer(data: data)!
	let pdfContext = CGContext(consumer: pdfConsumer, mediaBox: &pageRect, nil)!

	// Create four pages
	for index in 1 ... 4 {

		// Start a new page of the required size
		pdfContext.beginPage(mediaBox: &pageRect)

		pdfContext.saveGState()

		pdfContext.fill([CGRect(x: 10, y: 10, width: 40, height: 40)])

		// Add some text
		let text = "This is a PDF created with PDFKit (Page \(index))"
		let attributes: [NSAttributedString.Key: Any] = [
			.font: NSFont.systemFont(ofSize: 24),
			.foregroundColor: NSColor.black
		]

		let attributedString = NSAttributedString(string: text, attributes: attributes)

		let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
		let path = CGPath(rect: pageRect, transform: nil)
		let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, text.count), path, nil)
		CTFrameDraw(frame, pdfContext)

		pdfContext.restoreGState()

		pdfContext.endPage()
	}

	pdfContext.closePDF()

	return data as Data
}

#endif
