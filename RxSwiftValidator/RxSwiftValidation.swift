//
//  RxSwiftValidation.swift
//  Tethr
//
//  Created by Ian MacCallum on 5/10/17.
//  Copyright © 2017 Ian MacCallum. All rights reserved.
//

import Foundation
import RxSwift
import SwiftValidators
import SwiftValidator

public protocol Validatable {}

public protocol ValidationResultType {
	associatedtype ValueType
	var value: ValueType { get }
	var errorMessages: [String]? { get }
}


public struct ValidationResult<T: Validatable>: ValidationResultType {
	public typealias ValueType = T
	
	public var value: T
	public var errorMessages: [String]?
	
	init(value: T, errorMessages: [String]? = nil) {
		self.errorMessages = errorMessages
		self.value = value
	}
}



public protocol Rule {
	associatedtype ValidationType
	func errorMessage(for value: ValidationType) -> String?
}

public enum StringRule: Rule {

	case minLength(Int)
	case maxLength(Int)
	case length(min: Int, max: Int)
	case email
	case password
	case phoneNumber
	case regex(String, String?)
	case rule(SwiftValidator.Rule)
	
	public func errorMessage(for value: String) -> String? {
		
		switch self {
		case .minLength(let min):
			let rule = MinLengthRule(length: min)
			return rule.validate(value) ? nil : rule.errorMessage()
			
		case .maxLength(let max):
			let rule = MaxLengthRule(length: max)
			return rule.validate(value) ? nil : rule.errorMessage()
			
		case .length(min: let min, max: let max):
			let minRule = MinLengthRule(length: max)
			let maxRule = MaxLengthRule(length: max)
			let isValid = minRule.validate(value) && maxRule.validate(value)
			return isValid ? nil : "Invalid lemgth: must be between \(min) and \(max)"
		
		case .email:
			let rule = EmailRule(message: "Invalid email address")
			return rule.validate(value) ? nil : rule.errorMessage()
		
		case .password:
			let rule = PasswordRule(message: "Invalid password")
			return rule.validate(value) ? nil : rule.errorMessage()
			
		case .phoneNumber:
			let rule = PhoneNumberRule(message: "Invalid phone number")
			return rule.validate(value) ? nil : rule.errorMessage()

		case .regex(let pattern, let message):
			let rule = RegexRule(regex: pattern, message: message ?? "Invalid regex")
			return rule.validate(value) ? nil : rule.errorMessage()
			
		case .rule(let rule):
			return rule.validate(value) ? nil : rule.errorMessage()
		}
	}
}


public enum IntRule: Rule {
	
	case notZero
	case greaterThan(Int)
	case greaterThanOrEqualTo(Int)
	case lessThan(Int)
	case lessThanOrEqualTo(Int)
	case equalTo(Int)
	case positive
	case negative
	
	public func errorMessage(for value: Int) -> String? {
		
		switch self {
		case .notZero: return value != 0 ? nil : "\(value) can not be zero"
		case .greaterThan(let n): return value > n ? nil : "\(value) is not greater than \(n)"
		case .greaterThanOrEqualTo(let n): return value >= n ? nil : "\(value) is not greater than or qual to \(n)"
		case .lessThan(let n): return value < n ? nil : "\(value) is not less than \(n)"
		case .lessThanOrEqualTo(let n): return value <= n ? nil : "\(value) is not less than or equal to \(n)"
		case .equalTo(let n): return value == n ? nil : "\(value) is not equal to \(n)"
		case .positive: return value > 0 ? nil : "\(value) is not positive"
		case .negative: return value < 0 ? nil : "\(value)  is not negative"
		}
	}
	
	var errorMessage: String {
		return "Error"
	}
}

extension String: Validatable {}
extension Int: Validatable {}


public extension ObservableType where E: Validatable {
	
	func validate<T: Rule>(_ rules: T...) -> Observable<ValidationResult<Self.E>> where Self.E == T.ValidationType {
		return self.map { value -> ValidationResult<Self.E> in
			
			var result = ValidationResult<Self.E>(value: value, errorMessages: nil)

			let errorMessages = rules.flatMap { $0.errorMessage(for: value) }
			
			if !errorMessages.isEmpty {
				result.errorMessages = errorMessages
			}
			
			return result
		}
	}
	
	func validate<T: Rule>(rule: T) -> Observable<ValidationResult<Self.E>> where Self.E == T.ValidationType {
		return self.map { value -> ValidationResult<Self.E> in

			if let message = rule.errorMessage(for: value) {
				return ValidationResult<Self.E>(value: value, errorMessages: [message])
			} else {
				return ValidationResult<Self.E>(value: value)
			}
		}
	}
}


public extension Observable where Element: ValidationResultType, Element.ValueType: Validatable {
    
    func isValid() -> Observable<Bool> {
        return self.flatMap { result -> Observable<Bool> in
            if result.errorMessages == nil {
                return .just(true)
            } else {
                return .just(false)
            }
        }
    }
    
	func onValid() -> Observable<Element.ValueType> {
		return self.flatMap { result -> Observable<Element.ValueType> in
			if result.errorMessages == nil {
				return .just(result.value)
			} else {
				return .empty()
			}
		}
	}
	
	func onInvalid() -> Observable<[String]> {
		return self.flatMap { result -> Observable<[String]> in
			
			if let errorMessages = result.errorMessages {
				return .just(errorMessages)
			} else {
				return .empty()
			}
		}
	}
}
