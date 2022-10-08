//
//  ThemeFontsLinting.swift
//  FormsPlayground
//
//  Created by Michal on 07/10/2022.
//

import Foundation

//MARK: - Logic
struct FontMatch {
    let name: String
    let range: Range<String.Index>
}

enum FontFramework: String, CustomStringConvertible {
    case uikit = "UIFont"
    case swiftui = "SwiftUI.Font"
    
    var counterpart: Self {
        switch self {
        case .uikit: return .swiftui
        case .swiftui: return .uikit
        }
    }
    
    var description: String {
        self.rawValue
    }
}

func getFontNames(using pattern: String, from text: String) -> [FontMatch] {
    guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
        return []
    }
    
    let matches = regex.matches(in: text, options: [], range: NSRange(text.startIndex..<text.endIndex, in: text))
    return matches.compactMap { match -> FontMatch? in
        let matchRange = match.range(withName: "name")
        guard let range = Range(matchRange, in: text) else { return nil }
        return FontMatch(name: String(text[range]), range: range)
    }
}

func findMissingFontsFrom(uikitFonts:[FontMatch], swiftuiFonts: [FontMatch]) -> (uikit: [FontMatch], swiftui: [FontMatch]) {
    let uikitFontNames = Set(uikitFonts.map({ $0.name }))
    let swiftuiFontNames = Set(swiftuiFonts.map({ $0.name }))

    let diffs = uikitFontNames.symmetricDifference(swiftuiFontNames)

    let uikitFontsWithMissingCounterparts = uikitFonts.filter { diffs.contains($0.name) }
    let swiftuiFontsWithMissingCounterparts = swiftuiFonts.filter{ diffs.contains($0.name) }
    
    return (uikitFontsWithMissingCounterparts, swiftuiFontsWithMissingCounterparts)
}

//MARK: - Helpers
func reportMissingFonts(_ colors: [FontMatch], from framework: FontFramework, in code: String, fileName: String) {
    let codeLines = code.components(separatedBy:"\n")
    
    colors.forEach {
        let lineNumber = code[..<$0.range.lowerBound].components(separatedBy:"\n").count
        
        guard lineNumber - 1 <= codeLines.count, !(codeLines[lineNumber - 1].lowercased().contains("themelint:disable fonts")) else {
            return
        }
        
        reportWarning("\(framework) named `\($0.name)` does not have \(framework.counterpart) counterpart", file: fileName, line: lineNumber)
    }
}

func reportWarning(_ message: String, file: String = #file, line: Int = #line) {
    print("\(file):\(line): warning: \(message)")
}

//MARK: - Script
print("Verifying missing fonts in the Theme")

guard CommandLine.arguments.count >= 2 else {
    reportWarning("[ThemeLint] Missing path to the file with Colors")
    exit(0)
}

let filePath = CommandLine.arguments[1]

do {
    let fileContent = try String(contentsOfFile: filePath)
    let uikitFonts = getFontNames(using: #"static\s+let\s+`{0,1}(?<name>\S+?)[`\/=\-+!*%<>&|^~?:.,;\\()\s]+\S*\s*=\s*(?>UIKit.){0,1}UIFont"#, from: fileContent)
    let swiftuiFonts = getFontNames(using: #"static\s+let\s+`{0,1}(?<name>\S+?)[`\/=\-+!*%<>&|^~?:.,;\\()\s]+\S*\s*=\s*(?>SwiftUI.){0,1}Font"#, from: fileContent)
    
    let missingFonts = findMissingFontsFrom(uikitFonts: uikitFonts, swiftuiFonts: swiftuiFonts)
    reportMissingFonts(missingFonts.uikit, from: .uikit, in: fileContent, fileName: filePath)
    reportMissingFonts(missingFonts.swiftui, from: .swiftui, in: fileContent, fileName: filePath)
} catch {
    reportWarning("[ThemeLint] Could not open file at `\(filePath)`")
    exit(0)
}
