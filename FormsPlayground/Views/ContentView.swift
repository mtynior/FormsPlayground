//
//  ContentView.swift
//  FormsPlaygrounds
//
//  Created by Michal on 14/07/2022.
//

import SwiftUI

struct ContentView: View {
    @State var login: String = ""
    @State var password: String = ""
    @State var rePassword: String = ""
    
    var body: some View {
        FPForm { formReader in
            FPTextField(text: $login, id: "login")
                .label("Login")
                .placeholder("Enter login")
                .setValidators([Validators.required])
            
            FPTextField(text: $password, id: "password")
                .label("Password")
                .placeholder("Enter password")
                .counterVisible(true)
                .setValidators([Validators.required, Validators.lenght])
                .limit(10)
            
            /*Group {
                FPTextField(text: $password, id: "password1")
                    .label("Password")
                
                FPTextField(text: $password, id: "password2")
                    .label("Password")
                
                FPTextField(text: $password, id: "password3")
                    .label("Password")
                
                FPTextField(text: $password, id: "password4")
                    .label("Password")
                
                FPTextField(text: $password, id: "password5")
                    .label("Password")
                
                FPTextField(text: $password, id: "password7")
                    .label("Password")
                
                FPTextField(text: $password, id: "password8")
                    .label("Password")
                
                FPTextField(text: $password, id: "password9")
                    .label("Password")
                
                FPTextField(text: $password, id: "password10")
                    .label("Password")
                
                VStack {
                    HStack {
                        FPTextField(text: $rePassword, id: "password11")
                            .label("Repassword")
                            .setValidators([Validators.required, Validators.lenght])
                    }
                }
            }*/
            
            Button("Login", action: { formReader.validate() })
                .buttonStyle(.borderedProminent)
            
            Button("Reset", action: { formReader.clearErrors() })
                .buttonStyle(.plain)
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// MARK: - Helpers
enum Validators {
    static func `required`(value: Any?) -> String? {
        guard let stringValue = value as? String else { return nil }
        return stringValue.isEmpty ? "This field is required" : nil
    }
    
    static func lenght(value: Any?) -> String? {
        guard let stringValue = value as? String else { return nil }
        return stringValue.count < 5 ? "This field must have at least 5 characters" : nil
    }
}

