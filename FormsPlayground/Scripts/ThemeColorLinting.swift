//
//  ThemeColorLinting.swift
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

enum ColorFramework: String, CustomStringConvertible {
    case uikit = "UIColor"
    case swiftui = "SwiftUI.Color"
    
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
func reportMissingColors(_ colors: [ColorMatch], from framework: ColorFramework, in code: String, fileName: String) {
    let codeLines = code.components(separatedBy:"\n")
    
    colors.forEach {
        let lineNumber = code[..<$0.range.lowerBound].components(separatedBy:"\n").count
        
        guard lineNumber - 1 <= codeLines.count, !(codeLines[lineNumber - 1].lowercased().contains("themelint:disable colors")) else {
            return
        }
        
        reportWarning("\(framework) named `\($0.name)` does not have \(framework.counterpart) counterpart", file: fileName, line: lineNumber)
    }
}

func reportWarning(_ message: String, file: String = #file, line: Int = #line) {
    print("\(file):\(line): warning: \(message)")
}

//MARK: - Script
print("Verifying missing colors in the Theme")

guard CommandLine.arguments.count >= 2 else {
    reportWarning("[ThemeLint] Missing path to the file with Colors")
    exit(0)
}

let filePath = CommandLine.arguments[1]

do {
    let fileContent = try String(contentsOfFile: filePath)
    let uikitColors = getColorNames(using: #"static\s+let\s+`{0,1}(?<name>\S+?)[`\/=\-+!*%<>&|^~?:.,;\\()\s]+\S*\s*=\s*(?>UIKit.){0,1}UIColor"#, from: fileContent)
    let swiftuiColors = getColorNames(using: #"static\s+let\s+`{0,1}(?<name>\S+?)[`\/=\-+!*%<>&|^~?:.,;\\()\s]+\S*\s*=\s*(?>SwiftUI.){0,1}Color"#, from: fileContent)
    
    let missingColors = findMissingColorsFrom(uikitColors: uikitColors, swiftuiColors: swiftuiColors)
    reportMissingColors(missingColors.uikit, from: .uikit, in: fileContent, fileName: filePath)
    reportMissingColors(missingColors.swiftui, from: .swiftui, in: fileContent, fileName: filePath)
} catch {
    reportWarning("[ThemeLint] Could not open file at `\(filePath)`")
}

exit(0)
