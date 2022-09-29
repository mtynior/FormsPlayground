//
//  FPScrollView.swift
//  FormsPlayground
//
//  Created by Michal on 29/09/2022.
//

import SwiftUI

struct FPScrollView<Content: View>: View {
    @ObservedObject var viewModel: FPScrollViewViewModel
    let content: () -> Content
    
    public init(_ axes: Axis.Set = .vertical, showsIndicators: Bool = true, @ViewBuilder content: @escaping () -> Content) {
        self.viewModel = FPScrollViewViewModel(axes: axes, showsIndicators: showsIndicators)
        self.content = content
    }
    
    var body: some View {
        if #available(iOS 16.0, *) {
            ScrollView(viewModel.axes, showsIndicators: viewModel.showsIndicators) {
                content()
            }
            .scrollDisabled(viewModel.isScrollDisabled)
        } else {
            if viewModel.isScrollDisabled {
                content()
            } else {
                ScrollView(viewModel.axes, showsIndicators: viewModel.showsIndicators) {
                    content()
                }
            }
        }
    }
    
    func scrollDisabled(_ isScrollDisabled: Bool) -> Self {
        viewModel.isScrollDisabled = isScrollDisabled
        return self
    }
}

final class FPScrollViewViewModel: ObservableObject {
    @Published var axes: Axis.Set
    @Published var showsIndicators: Bool
    @Published var isScrollDisabled: Bool
    
    init(axes: Axis.Set, showsIndicators: Bool, isScrollDisabled: Bool = false) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.isScrollDisabled = isScrollDisabled
    }
}

struct FPScrollView_Previews: PreviewProvider {
    static var previews: some View {
        FPScrollView() {
            Text("")
        }
    }
}
