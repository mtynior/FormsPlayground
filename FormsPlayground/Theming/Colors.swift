//
//  Colors.swift
//  FormsPlayground
//
//  Created by Michal on 07/10/2022.
//

import SwiftUI

public extension UIColor {
    static let myColor1 = UIColor(named: "myColor1")
    static let myColor2 = UIColor(named: "myColor2")    //themelint:disable colors
    static let myColor3 = UIColor(named: "myColor3")
    static let 🙈 = UIColor(named: "myColor4")
    static let myColor5 = UIColor(named: "myColor5")
    static let myColor6 = UIColor(named: "myColor6")
}

public extension Color {
    enum Palette {
        public static let myColor1 = Color("myColor1")
        public static let `let` = Color("myColor2")
        public static let myColor3 = Color("myColor3")
        public static let myColor4 = Color("myColor4")
        public static let myColor5 = Color("myColor5")
        public static let myColor7 = Color("myColor7")
    }
}
