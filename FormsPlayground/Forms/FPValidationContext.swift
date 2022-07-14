//
//  FPValidationContext.swift
//  FormsPlaygrounds
//
//  Created by Michal on 14/07/2022.
//

import Foundation

public typealias Validator = (Any?) -> String?

public final class FPValidationContext: ObservableObject {
    var validators: [Validator] = []
    var errorMessage: String? = nil
    var validationErrors: [String] = []
    var valueEvaluator: (() -> Any?)?
    
    var currentError: String? {
        if let errorMessage = errorMessage, !errorMessage.isEmpty {
            return errorMessage
        }
        return validationErrors.first
    }
    
    @discardableResult func validate() -> [String] {
        if let errorMessage = errorMessage {
            return [errorMessage]
        }
        
        let evaluatedValue = valueEvaluator?()
        validationErrors = validators.map({ $0(evaluatedValue) }).compactMap({ $0 })
        objectWillChange.send()
        return validationErrors
    }
    
    func clearErrors() {
        errorMessage = nil
        validationErrors = []
        objectWillChange.send()
    }
}
