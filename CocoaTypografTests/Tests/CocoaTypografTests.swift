//
//  CocoaTypografTests.swift
//  CocoaTypografTests
//
//  Created by Vadim Zhilinkov on 04/09/2018.
//  Copyright © 2018 dreadct. All rights reserved.
//

import XCTest

final class CocoaTypografTests: XCTestCase {

    // MARK: - Properties

    var service: TypografService!
    let timeout: TimeInterval = 30.0

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()

        service = ConcreteTypografService()
    }

    override func tearDown() {
        service = nil
        super.tearDown()
    }

}

// MARK: - Test methods

extension CocoaTypografTests {

    func testCancellation() {
        let token = process(text: "") { _ in
            XCTFail("Operation wasn't cancelled")
        }
        token.cancel()

        let dispatchExpectation = expectation(description: "A dispatch expectation")
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.postCancellationDelay) {
            dispatchExpectation.fulfill()
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testNbspProcessing() {
        let responseExpectation = expectation(description: "Wait for response for text")
        process(text: Constants.nbspSourceString) { responseText in
            responseExpectation.fulfill()
            XCTAssertEqual(Constants.nbspExpectedString, responseText)
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }

    func testQuotesProcessing() {
        let responseExpectation = expectation(description: "Wait for response for text")
        process(text: Constants.quotesSourceString) { responseText in
            responseExpectation.fulfill()
            XCTAssertEqual(Constants.quotesExpectedString, responseText)
        }

        waitForExpectations(timeout: timeout, handler: nil)
    }

}

// MARK: - Private methods

extension CocoaTypografTests {

    @discardableResult
    private func process(text: String,
                         completion: @escaping (String) -> Void) -> OperationToken {
        let params = ProcessTextParameters(text: text)
        return service.processText(parameters: params) { result in
            switch result {
            case .failure(let error):
                XCTFail(error.localizedDescription)
            case .success(let text):
                completion(text)
            }
        }
    }

}

// MARK: - Constants

extension CocoaTypografTests {

    fileprivate enum Constants {
        static let nbspSourceString = NSLocalizedString("test.nbsp.source",
                                                        tableName: "Test",
                                                        bundle: Bundle.current,
                                                        comment: "")
        static let nbspExpectedString = NSLocalizedString("test.nbsp.expected",
                                                          tableName: "Test",
                                                          bundle: Bundle.current,
                                                          comment: "")
        static let quotesSourceString = NSLocalizedString("test.quotes.source",
                                                          tableName: "Test",
                                                          bundle: Bundle.current,
                                                          comment: "")
        static let quotesExpectedString = NSLocalizedString("test.quotes.expected",
                                                            tableName: "Test",
                                                            bundle: Bundle.current,
                                                            comment: "")
        static let postCancellationDelay: TimeInterval = 1.0
    }

}
