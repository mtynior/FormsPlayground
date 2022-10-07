//
//  ThemeColorVerification.swift
//  FormsPlayground
//
//  Created by Michal on 07/10/2022.
//

import Foundation

//MARK: - Logic
struct ColorMatch {
    let name: String
    let range: Range<String.Index>
}

func getColorNames(using pattern: String, from text: String) -> [ColorMatch] {
    guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
        return []
    }
    
    let matches = regex.matches(in: text, options: [], range: NSRange(text.startIndex..<text.endIndex, in: text))
    return matches.compactMap { match -> ColorMatch? in
        let matchRange = match.range(withName: "name")
        guard let range = Range(matchRange, in: text) else { return nil }
        return ColorMatch(name: String(text[range]), range: range)
    }
}

func findMissingColorsFrom(uikitColors:[ColorMatch], swiftuiColors: [ColorMatch]) -> (uikit: [ColorMatch], swiftui: [ColorMatch]) {
    let uikitColorNames = Set(uikitColors.map({ $0.name }))
    let swiftuiColorNames = Set(swiftuiColors.map({ $0.name }))

    let diffs = uikitColorNames.symmetricDifference(swiftuiColorNames)

    let uikitColorsWithMissingCounterparts = uikitColors.filter { diffs.contains($0.name) }
    let swiftuiColorsWithMissingCounterparts = swiftuiColors.filter{ diffs.contains($0.name) }
    
    return (uikitColorsWithMissingCounterparts, swiftuiColorsWithMissingCounterparts)
}

//MARK: - Helpers
func reportMissingUIKitColors(_ colors: [ColorMatch], from code: String, file: String) {
    colors.forEach {
        let lineNumber = code[..<$0.range.lowerBound].components(separatedBy:"\n").count
        reportWarning("UIColor named `\($0.name)` does not have SwiftUI.Color counterpart", file: file, line: lineNumber)
    }
}

func reportMissingSwiftUIColors(_ colors: [ColorMatch], from code: String, file: String) {
    colors.forEach {
        let lineNumber = code[..<$0.range.lowerBound].components(separatedBy:"\n").count
        reportWarning("SwiftUI.Color named `\($0.name)` does not have UIColor counterpart", file: file, line: lineNumber)
    }
}

func reportWarning(_ message: String, file: String = #file, line: Int = #line) {
    print("\(file):\(line): warning: \(message)")
}

//MARK: - Script
print("Verifying missing colors in the Theme")

guard CommandLine.arguments.count >= 2 else {
    reportWarning("[ThemeColorVerification] Missing path to the file with Colors")
    exit(0)
}

let filePath = CommandLine.arguments[1]

do {
    let fileContent = try String(contentsOfFile: filePath)
    let uikitColors = getColorNames(using: "UIColor\\(named:\\s*\"(?<name>.*)\"\\)", from: fileContent)
    let swiftuiColors = getColorNames(using: "Color\\(\"(?<name>.*)\"\\)", from: fileContent)
    
    let missingColors = findMissingColorsFrom(uikitColors: uikitColors, swiftuiColors: swiftuiColors)
    reportMissingUIKitColors(missingColors.uikit, from: fileContent, file: filePath)
    reportMissingSwiftUIColors(missingColors.swiftui, from: fileContent, file: filePath)    
} catch {
    reportWarning("[ThemeColorVerification] Could not open file at `\(filePath)`")
    exit(0)
}
