# RxSwiftValidator
A lightweight set of generic validation operators for Observable types


## Installation
1. Download Project
2. Run: `pod install`
3. Drop 'RxSwiftValidator' into your project. I'll probably add Cocoapods and Carthage support when it becomes more mature.
Note: [SwiftValidator](https://github.com/jpotts18/SwiftValidator) and RxSwift are dependencies so keep that in mind.

## Contributing
Feel free to contribute. I'll review pull requests asap.


## Sample Usage

```
// Email
Observable.just(validEmail).validate(StringRule.email).onValid().subscribe(onNext: { validated in
  print("validated: \(validated)")
}).addDisposableTo(disposeBag)
		
Observable.just(invalidEmail).validate(StringRule.email).onValid().subscribe(onNext: { validated in
  // Never
}).addDisposableTo(disposeBag)
		
Observable.just(validEmail).validate(StringRule.email).onInvalid().subscribe(onNext: { errors in
  // Never
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
  // Never
}).addDisposableTo(disposeBag)
		
Observable.just(validPhoneNumber).validate(StringRule.phoneNumber).onInvalid().subscribe(onNext: { errors in
  // Never
}).addDisposableTo(disposeBag)
		
Observable.just(invalidPhoneNumber).validate(StringRule.phoneNumber).onInvalid().subscribe(onNext: { errors in
  print(errors)
  XCTAssert(errors.count > 0)
}).addDisposableTo(disposeBag)
```
