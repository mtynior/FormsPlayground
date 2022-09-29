//
//  FPForm.swift
//  FormsPlaygrounds
//
//  Created by Michal on 14/07/2022.
//

import SwiftUI

struct FPForm<Content: View>: View {
    @ObservedObject private var formReader = FormReader()
    var content: (FormReader) -> Content
    
    init(@ViewBuilder content: @escaping (FormReader) -> Content) {
        self.content = content
    }
    
    var body: some View {
        FPScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                content(formReader)
            }
            .environmentObject(formReader)
            
        }
        .scrollDisabled(true)
        .padding(.horizontal)
    }
}

public class FormReader: ObservableObject {
    let id: String = UUID().uuidString
    
    init() {
        print("Init FormReader \(id)")
    }
    
    deinit {
        print("Deinit FormReader \(id)")
    }
    
    var validators: [(id: String, value: FPValidationContext)] = []
    
    func setValidationContext(_ validationContext: FPValidationContext?, forInputWithId id: String) {
        if let index = validators.firstIndex(where: { $0.id == id }) {
            if let validationContext = validationContext {
                validators[index] = (id, validationContext)
            } else {
                validators.remove(at: index)
            }
        } else if let validationContext = validationContext {
            validators.append((id, validationContext))
        }
    }
    
    @discardableResult func validate() -> Bool {
        return validators.flatMap({ $0.value.validate() }).isEmpty
    }
    
    func clearErrors() {
        validators.forEach{ $0.value.clearErrors() }
    }
}
