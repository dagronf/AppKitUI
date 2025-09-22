import XCTest
@testable import AppKitUI

final class AppKitUITests: XCTestCase {
	func testSomeAllNoneSatisfy() throws {
		let c1 = [80, 85, 90, 75]

		XCTAssertTrue(c1.allSatisfy { $0 >= 75 } )
		XCTAssertFalse(c1.allSatisfy { $0 < 90 } )

		XCTAssertTrue(c1.someSatisfy { $0 >= 80 } )
		XCTAssertTrue(c1.someSatisfy { $0 == 85 } )
		XCTAssertFalse(c1.someSatisfy { $0 > 90 } )
		XCTAssertFalse(c1.someSatisfy { $0 < 75 } )

		XCTAssertTrue(c1.noneSatisfy { $0 > 90 } )
		XCTAssertTrue(c1.noneSatisfy { $0 < 50 } )
		XCTAssertFalse(c1.noneSatisfy { $0 >= 80 } )
	}

	func testArrayAt() throws {
		let c1 = [80, 85, 90, 75]
		XCTAssertEqual(80, c1.at(0))
		XCTAssertEqual(75, c1.at(3))
		XCTAssertEqual(nil, c1.at(-1))
		XCTAssertEqual(nil, c1.at(4))

		// Make sure we handle an empty array correctly
		var c2: [Int] = []
		XCTAssertEqual(nil, c2.at(-1))
		XCTAssertEqual(nil, c2.at(0))
		XCTAssertEqual(nil, c2.at(1))

		c2 = [1]
		XCTAssertEqual(nil, c2.at(-1))
		XCTAssertEqual(1, c2.at(0))
		XCTAssertEqual(nil, c2.at(1))
	}
}
