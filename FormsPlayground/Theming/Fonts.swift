//
//  Fonts.swift
//  FormsPlayground
//
//  Created by Michal on 07/10/2022.
//

import SwiftUI

public enum Font {
    static let systemStandardLight = UIFont.systemFont(ofSize: 14, weight: .light)
    static let systemStandardRegular: UIFont =    UIFont.systemFont(ofSize: 14, weight: .regular)
    static let systemStandardMedium = UIFont.systemFont(ofSize: 14, weight: .medium)
    private static  let  systemStandardBold = UIFont.systemFont(ofSize: 14, weight: .bold)
        
    static let systemSmallBold = UIFont.systemFont(ofSize: 8, weight: .bold)
}

public extension SwiftUI.Font {
    static let systemStandardLight = SwiftUI.Font.system(size: 14, weight: .light)
    static let systemStandardRegular = SwiftUI.Font.system(size: 14, weight: .regular)
    static let systemStandardMedium = SwiftUI.Font.system(size: 14, weight: .medium)
    static let systemStandardBold = SwiftUI.Font.system(size: 14, weight: .bold)

    static let systemSmalldRegular = SwiftUI.Font.system(size: 8, weight: .regular)
}
