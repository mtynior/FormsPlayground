//
//  BindingView.swift
//  FormsPlayground
//
//  Created by Michal on 03/10/2022.
//

import SwiftUI

struct BindingView: View {
    @State var amount: String = "250.44"
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Amount", text: $amount)
                .keyboardType(.decimalPad)
            
            let o:Decimal? = $amount.decimalBinding().wrappedValue
            
            Text("\(String(describing: $amount.decimalBinding().wrappedValue))")
            Text("\(String(describing: o))")

        }
        .padding()
    }
}

/*
struct OptionalDecimalStringBinding {
    var decimalProxy: Binding<Decimal?>
    var stringProxy: Binding<String>
    
    static let decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.decimalSeparator = "."
        formatter.numberStyle = .decimal
        formatter.generatesDecimalNumbers = true
        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter
    }()
    
    init(decimalProxy: Binding<Decimal?>) {
        self.decimalProxy = decimalProxy
        self.stringProxy = Binding<String>(
            get: {
                guard let number = decimalProxy.wrappedValue else { return "" }
                let v = Self.decimalFormatter.string(from: NSDecimalNumber(decimal: number) ) ?? ""
                print("get: \(String(describing: decimalProxy.wrappedValue)) -> \(v)")
                return v
            },
            set: {
                let v = Self.decimalFormatter.number(from: $0) as? Decimal
                print("set: \($0) -> \(String(describing: v))")
                decimalProxy.wrappedValue = v
            }
        )
    }
    
}
*/

extension Binding where Value == Decimal? {
    public func stringBinding() -> Binding<String> {
        let decimalFormatter = NumberFormatter()
        decimalFormatter.decimalSeparator = "."
        decimalFormatter.numberStyle = .decimal
        decimalFormatter.generatesDecimalNumbers = true
        decimalFormatter.groupingSeparator = ""
        decimalFormatter.maximumFractionDigits = 2
        
        return Binding<String>(
            get:{
                guard let number = self.wrappedValue else { return "" }
                let v = decimalFormatter.string(from: NSDecimalNumber(decimal: number) ) ?? ""
                print("get ext: \(String(describing: self.wrappedValue)) -> \(v)")
                return v
            },
            set: {
                let v = decimalFormatter.number(from: $0) as? Decimal
                print("set: \($0) -> \(String(describing: v))")
                self.wrappedValue = v
            }
        )
    }
}

extension Binding where Value == String {
    public func decimalBinding() -> Binding<Decimal?> {
        let decimalFormatter = NumberFormatter()
        decimalFormatter.decimalSeparator = "."
        decimalFormatter.numberStyle = .decimal
        decimalFormatter.generatesDecimalNumbers = true
        decimalFormatter.groupingSeparator = ""
        decimalFormatter.maximumFractionDigits = 2
        
        return Binding<Decimal?>(
            get:{
                let v =  decimalFormatter.number(from: self.wrappedValue)
                print("get ext: \(String(describing: self.wrappedValue)) -> \(String(describing: v))")
                return v as? Decimal
            },
            set: {
                if let val = $0 {
                    self.wrappedValue = decimalFormatter.string(from: NSDecimalNumber(decimal: val)) ?? ""
                } else {
                    self.wrappedValue = ""
                }
                print("set ext: \(String(describing: $0)) -> \(String(describing: self.wrappedValue))")
            }
        )
    }
    
    public func decimalBinding() -> Binding<Decimal> {
        let decimalFormatter = NumberFormatter()
        decimalFormatter.decimalSeparator = "."
        decimalFormatter.numberStyle = .decimal
        decimalFormatter.generatesDecimalNumbers = true
        decimalFormatter.groupingSeparator = ""
        decimalFormatter.maximumFractionDigits = 2
        
        return Binding<Decimal>(
            get:{
                let v =  decimalFormatter.number(from: self.wrappedValue)
                print("get extOpt: \(String(describing: self.wrappedValue)) -> \(String(describing: v))")
                return v as? Decimal ?? 0.00
            },
            set: {
                self.wrappedValue = decimalFormatter.string(from: NSDecimalNumber(decimal: $0)) ?? ""
                print("set extOpt: \(String(describing: $0)) -> \(String(describing: self.wrappedValue))")
            }
        )
    }
}

