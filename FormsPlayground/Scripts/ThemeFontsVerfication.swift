//
//  ThemeFontsVerfication.swift
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
func reportMissingUIKitFonts(_ fonts: [FontMatch], from code: String, file: String) {
    fonts.forEach {
        let lineNumber = code[..<$0.range.lowerBound].components(separatedBy:"\n").count
        reportWarning("UIFont named `\($0.name)` does not have SwiftUI.Font counterpart", file: file, line: lineNumber)
    }
}

func reportMissingSwiftUIFonts(_ fonts: [FontMatch], from code: String, file: String) {
    fonts.forEach {
        let lineNumber = code[..<$0.range.lowerBound].components(separatedBy:"\n").count
        reportWarning("SwiftUI.Font named `\($0.name)` does not have UIFont counterpart", file: file, line: lineNumber)
    }
}

func reportWarning(_ message: String, file: String = #file, line: Int = #line) {
    print("\(file):\(line): warning: \(message)")
}

//MARK: - Script
print("Verifying missing fonts in the Theme")

guard CommandLine.arguments.count >= 2 else {
    reportWarning("[ThemeFontsVerfication] Missing path to the file with Colors")
    exit(0)
}

let filePath = CommandLine.arguments[1]

do {
    let fileContent = try String(contentsOfFile: filePath)
    let uikitFonts = getFontNames(using: "static\\s+let\\s+(?<name>\\S*)(?>\\s*:\\s*UIFont)?\\s*=\\s*UIFont", from: fileContent)
    let swiftuiFonts = getFontNames(using: "static\\s+let\\s+(?<name>\\S*)(?>\\s*:\\s*SwiftUI.Font)?\\s*=\\s*SwiftUI.Font", from: fileContent)
    
    let missingFonts = findMissingFontsFrom(uikitFonts: uikitFonts, swiftuiFonts: swiftuiFonts)
    reportMissingUIKitFonts(missingFonts.uikit, from: fileContent, file: filePath)
    reportMissingSwiftUIFonts(missingFonts.swiftui, from: fileContent, file: filePath)
} catch {
    reportWarning("[ThemeFontsVerfication] Could not open file at `\(filePath)`")
    exit(0)
}
