//
//  FPTextField.swift
//  FormsPlaygrounds
//
//  Created by Michal on 14/07/2022.
//

import SwiftUI

public struct FPTextField: View {
    private let id: String
    @Binding var text: String
    @ObservedObject private var viewModel = FPTextFieldViewModel()
    @ObservedObject private var validationContext = FPValidationContext()
    @EnvironmentObject var validationManger: FormReader
    
    public init(text: Binding<String>, id: String) {
        self._text = text
        self.id = id
        self.validationContext.valueEvaluator = { text.wrappedValue }
    }
    
    public var body: some View {
        FPFormComponent(label: viewModel.label, modifiers: viewModel.componentModifiers, content: {
            TextField(text: $text, label: { Text(viewModel.placeholder ?? "") })
                .onChange(of: $text.wrappedValue) { value in
                    validationContext.validate()
                }
        }, footer: {
            Divider()
                .overlay(validationContext.currentError == nil ? Color.gray : Color.red )
            HStack {
                if let error = validationContext.currentError, !error.isEmpty {
                    Text(error)
                        .font(.system(size: 12)) // set this as TextStyle.FromErrorLabel
                        .foregroundColor(Color.red)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                if let counterTemplate = viewModel.counterTemplate {
                    Text(String(format: counterTemplate, text.count))
                        .font(.system(size: 12)) // set this as TextStyle.bottomLabel
                }
            }
        })
        .id(id)
        .onAppear {
            validationManger.setValidationContext(validationContext, forInputWithId: id)
        }
    }
}

// API
public extension FPTextField {
    func placeholder(_ placeholder: String?) -> Self {
        viewModel.placeholder = placeholder
        return self
    }
    
    func label(_ label: String?) -> Self {
        viewModel.label = label
        return self
    }
    
    func counterVisible(_ isVisble: Bool) -> Self {
        viewModel.isCounterVisible = isVisble
        return self
    }
    
    func limit(_ limit: Int?) -> Self {
        viewModel.limit = limit
        return self
    }
    
    func errorMessage(_ errorMessage: String?) -> Self {
        validationContext.errorMessage = errorMessage
        return self
    }
    
    func setValidators(_ validators: [Validator]) -> Self {
        validationContext.validators = validators
        return self
    }
    
    func addTooltip(tint: Color = Color.blue, action: @escaping () -> Void) -> Self {
        let modifier = TooltipFPFormComponentModifier(tint: tint, action: action)
        viewModel.componentModifiers.append(modifier)
        return self
    }
}

final class FPTextFieldViewModel: ObservableObject {
    @Published var placeholder: String?
    @Published var label: String?
    @Published var isCounterVisible: Bool
    @Published var limit: Int?
    @Published var componentModifiers: [any FPFormComponentModifier] = []
    
    init(
        placeholder: String? = nil,
        label: String? = nil,
        isCounterVisible: Bool = false,
        limit: Int? = nil
    ) {
        self.placeholder = placeholder
        self.label = label
        self.isCounterVisible = isCounterVisible
        self.limit = limit
    }
    
    var counterTemplate: String? {
        guard isCounterVisible else { return nil}
        
        let limit: String = {
            guard let limit = self.limit else { return "" }
            return "/\(limit)"
        }()
        
        return "%d\(limit)"
    }
}

// Preview
struct FPTextField_Previews: PreviewProvider {
    @State static var text = ""
    static var previews: some View {
        FPTextField(text: $text, id: "login")
            .placeholder("Enter value")
            .label("Login")
            .counterVisible(true)
            .padding()
    }
}
