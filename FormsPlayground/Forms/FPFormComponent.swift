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
    
    init(
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder footer: @escaping () -> Footer
    ) {
        self.label = label
        self.content = content
        self.footer = footer
    }

    var body: some View {
        VStack(spacing: 4) {
            label()
            content()
            footer()
        }
    }
}

extension FPFormComponent where Label == FPFormComponentLabel {
    init(
        label: String?,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder footer: @escaping () -> Footer
    ) {
        self.init(label: { FPFormComponentLabel(text: label) }, content: content, footer: footer)
    }
}

struct FPFormComponentLabel: View {
    var text: String?
    var body: some View {
        if let text = text, !text.isEmpty {
            HStack(spacing: 0) {
                Text(text)
                    .font(.system(size: 12))
                    .multilineTextAlignment(.leading)
                Spacer()
            }
        } else {
            EmptyView()
        }
    }
}
