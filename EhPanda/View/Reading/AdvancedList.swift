//
//  AdvancedList.swift
//  EhPanda
//
//  Created by 荒木辰造 on 2021/07/30.
//

import SwiftUI
import SwiftUIPager

struct AdvancedList<Element, ID, PageView, G>: View
where PageView: View, Element: Equatable, ID: Hashable, G: Gesture {
    @State var performingChanges = false

    private let pagerModel: Page
    private var data: [Element]
    private let id: KeyPath<Element, ID>
    private let spacing: CGFloat
    private let gesture: G
    private let content: (Element) -> PageView

    init<Data: RandomAccessCollection>(
        page: Page, data: Data,
        id: KeyPath<Element, ID>, spacing: CGFloat,
        gesture: G,
        @ViewBuilder content:
            @escaping (Element) -> PageView
    )
    where Data.Index == Int,
    Data.Element == Element
    {
        self.pagerModel = page
        self.data = Array(data)
        self.id = id
        self.spacing = spacing
        self.gesture = gesture
        self.content = content
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: spacing) {
                    ForEach(data, id: id) { index in
                        let longPress = LongPressGesture(
                            minimumDuration: 0,
                            maximumDistance: .infinity
                        ).onEnded { _ in
                            if let index = index as? Int {
                                performingChanges = true
                                pagerModel.update(
                                    .new(index: index - 1)
                                )
                                DispatchQueue.main.asyncAfter(
                                    deadline: .now() + 0.2
                                ) { performingChanges = false }
                            }
                        }
                        let gestures = longPress
                            .simultaneously(with: gesture)
                        content(index).gesture(gestures)
                    }
                }
                .task {
                    performScrollTo(id: pagerModel.index + 1, proxy: proxy)
                }
            }
            .onChange(of: pagerModel.index) { newValue in
                performScrollTo(id: newValue + 1, proxy: proxy)
            }
        }
    }

    private func performScrollTo(id: Int, proxy: ScrollViewProxy) {
        guard !performingChanges else { return }
        dispatchMainSync {
            proxy.scrollTo(id, anchor: .center)
        }
    }
}
