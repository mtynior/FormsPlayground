//
//  FPFormComponent.swift
//  FormsPlaygrounds
//
//  Created by Michal on 14/07/2022.
//

import SwiftUI

struct FPFormComponent<Label: View, Content: View, Footer: View>: View {
    var label: () -> Label
    var content: () -> Content
    var footer: () -> Footer
    let modifiersBuilder: ModifiersBuilder
    
    init(
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder footer: @escaping () -> Footer,
        modifiers: [FPFormComponentModifier] = []
    ) {
        self.label = label
        self.content = content
        self.footer = footer
        self.modifiersBuilder = ModifiersBuilder(modifiers: modifiers)
    }

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                modifiersBuilder.modifyLabel(label())
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            
            modifiersBuilder.modifyContent(content())
            footer()
        }
    }
    
    func labelModifier() -> Self {
        return self
    }
}

extension FPFormComponent where Label == FPFormComponentLabel {
    init(
        label: String?,
        modifiers: [FPFormComponentModifier],
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder footer: @escaping () -> Footer
    ) {
        self.init(label: { FPFormComponentLabel(text: label) }, content: content, footer: footer, modifiers: modifiers)
    }
}

struct FPFormComponentLabel: View {
    var text: String?
    var body: some View {
        if let text = text, !text.isEmpty {
                Text(text)
                    .font(.system(size: 12))
                    .multilineTextAlignment(.leading)
              
        } else {
            EmptyView()
        }
    }
}

final class ModifiersBuilder {
    let modifiers: [FPFormComponentModifier]
    
    init(modifiers: [FPFormComponentModifier]) {
        self.modifiers = modifiers
    }
    
    @MainActor func modifyLabel<L: View>(_ originalLabel: L) -> AnyView {
        var modifiedView: AnyView = AnyView(originalLabel)
        
        for index in modifiers.indices {
            let modifier = modifiers[index]
            modifiedView = modifier.label(modifiedView)
        }
        
        return modifiedView
    }
    
    @MainActor func modifyContent<C: View>(_ originalContent: C) -> AnyView {
        var modifiedView: AnyView = AnyView(originalContent)
        
        for index in modifiers.indices {
            let modifier = modifiers[index]
            modifiedView = modifier.content(modifiedView)
        }
        
        return modifiedView
    }
}

protocol FPFormComponentModifier {
    @MainActor @ViewBuilder func label<L: View>(_ label: L) -> AnyView
    @MainActor @ViewBuilder func content(_ content: AnyView) -> AnyView
}

struct TooltipFPFormComponentModifier: FPFormComponentModifier {
    let tint: Color
    let action: () -> Void
    
    init(tint: Color = .black, action: @escaping () -> Void) {
        self.tint = tint
        self.action = action
    }
    
    @MainActor @ViewBuilder func label<L: View>(_ label: L) -> AnyView {
        AnyView(
            HStack(spacing: 4) {
                label
                
                Image(systemName: "info.circle")
                    .resizable()
                    .frame(width: 16, height: 16)
                    .tint(tint)
                    .onTapGesture(perform: action)
            }
        )
    }
    
    @MainActor @ViewBuilder func content(_ content: AnyView) -> AnyView {
        content
    }
}
