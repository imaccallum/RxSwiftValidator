//
//  RxSwiftValidatorTests.swift
//  RxSwiftValidatorTests
//
//  Created by Ian MacCallum on 5/10/17.
//  Copyright © 2017 Ian MacCallum. All rights reserved.
//

import XCTest
@testable import RxSwiftValidator
import RxSwift
import RxTest
import RxBlocking

class RxSwiftValidatorTests: XCTestCase {
	
	var disposeBag: DisposeBag!
	
	override func setUp() {
		super.setUp()
		disposeBag = DisposeBag()
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		disposeBag = nil
		super.tearDown()
	}
	
	func testExample() {
		// This is an example of a functional test case.
		// Use XCTAssert and related functions to verify your tests produce the correct results.
	}
	
	func testPerformanceExample() {
		// This is an example of a performance test case.
		self.measure {
			// Put the code you want to measure the time of here.
		}
	}

	func testStringRules() {
		
		let validEmail = "johnsmith@gmail.com"
		let invalidEmail = "@32wiuonsx.ecom4"
		let validPhoneNumber = "3053842953"
		let invalidPhoneNumber = "848930"
		
		// Email
		Observable.just(validEmail).validate(StringRule.email).onValid().subscribe(onNext: { validated in
			print("validated: \(validated)")
			XCTAssert(validEmail == validated)
		}).addDisposableTo(disposeBag)
		
		Observable.just(invalidEmail).validate(StringRule.email).onValid().subscribe(onNext: { validated in
			XCTFail()
		}).addDisposableTo(disposeBag)
		
		Observable.just(validEmail).validate(StringRule.email).onInvalid().subscribe(onNext: { errors in
			XCTFail()
		}).addDisposableTo(disposeBag)
		
		Observable.just(invalidEmail).validate(StringRule.email).onInvalid().subscribe(onNext: { errors in
			print(errors)
			XCTAssert(errors.count > 0)
		}).addDisposableTo(disposeBag)
		
		
		// Phone number
		Observable.just(validPhoneNumber).validate(StringRule.phoneNumber).onValid().subscribe(onNext: { validated in
			print("validated: \(validated)")
			XCTAssert(validPhoneNumber == validated)
		}).addDisposableTo(disposeBag)
		
		Observable.just(invalidPhoneNumber).validate(StringRule.phoneNumber).onValid().subscribe(onNext: { validated in
			XCTFail()
		}).addDisposableTo(disposeBag)
		
		Observable.just(validPhoneNumber).validate(StringRule.phoneNumber).onInvalid().subscribe(onNext: { errors in
			XCTFail()
		}).addDisposableTo(disposeBag)
		
		Observable.just(invalidPhoneNumber).validate(StringRule.phoneNumber).onInvalid().subscribe(onNext: { errors in
			print(errors)
			XCTAssert(errors.count > 0)
		}).addDisposableTo(disposeBag)
		
		
		
	}
	
	
}
