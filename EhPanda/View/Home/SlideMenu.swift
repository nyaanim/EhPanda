//
//  SlideMenu.swift
//  EhPanda
//
//  Created by 荒木辰造 on R 3/02/18.
//

import SwiftUI
import Kingfisher

struct SlideMenu: View, StoreAccessor {
    @EnvironmentObject var store: Store
    @Environment(\.colorScheme) private var colorScheme

    @Binding private var offset: CGFloat
    private var edges = keyWindow?.safeAreaInsets

    private var menuItems: [HomeListType] {
        let excludedType: [HomeListType] = didLogin ? [.search, .downloaded]
            : [.search, .watched, .favorites, .downloaded]
        return HomeListType.allCases.filter { !excludedType.contains($0) }
    }

    init(offset: Binding<CGFloat>) {
        _offset = offset
    }

    // MARK: SlideMenu
    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                AvatarView(
                    iconName: iconType.iconName,
                    avatarURL: user.avatarURL,
                    displayName: user.displayName,
                    width: Defaults.ImageSize.avatarW,
                    height: Defaults.ImageSize.avatarH
                )
                .padding(.top, 40)
                .padding(.bottom, 20)
                Divider().padding(.vertical)
                ScrollView(showsIndicators: false) {
                    ForEach(menuItems) { item in
                        MenuRow(
                            isSelected: item == homeListType,
                            symbolName: item.symbolName,
                            text: item.rawValue,
                            action: { onMenuRowTap(item: item) }
                        )
                    }
                }
                Divider().padding(.vertical)
                MenuRow(
                    isSelected: false,
                    symbolName: "gear",
                    text: "Setting",
                    action: onSettingMenuRowTap
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, edges?.top == 0 ? 15 : edges?.top)
            .padding(.bottom, edges?.bottom == 0 ? 15 : edges?.bottom)
            .frame(width: Defaults.FrameSize.slideMenuWidth)
            .background(colorScheme == .light ? .white : .black)
            .edgesIgnoringSafeArea(.vertical)

            Spacer()
        }
    }
}

private extension SlideMenu {
    var width: CGFloat {
        Defaults.FrameSize.slideMenuWidth
    }
    var iconType: IconType {
        store.appState.settings.setting.appIconType
    }

    func onMenuRowTap(item: HomeListType) {
        if homeListType != item {
            store.dispatch(.toggleHomeList(type: item))
            impactFeedback(style: .soft)
            performTransition(offset: -width)
        }
    }
    func onSettingMenuRowTap() {
        store.dispatch(.toggleHomeViewSheet(state: .setting))
    }

    func performTransition(offset: CGFloat) {
        withAnimation {
            self.offset = offset
        }
    }
}

// MARK: AvatarView
private struct AvatarView: View {
    private let iconName: String
    private let avatarURL: String?
    private let displayName: String?

    private let width: CGFloat
    private let height: CGFloat

    init(
        iconName: String,
        avatarURL: String?,
        displayName: String?,
        width: CGFloat,
        height: CGFloat
    ) {
        self.iconName = iconName
        self.avatarURL = avatarURL
        self.displayName = displayName
        self.width = width
        self.height = height
    }

    private func getPlaceholder() -> some View {
        Image(iconName).resizable()
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Group {
                    if avatarURL?.contains(".gif") != true {
                        KFImage(URL(string: avatarURL ?? ""))
                            .placeholder(getPlaceholder)
                            .retry(maxCount: 10)
                            .defaultModifier(
                                withRoundedCorners: false
                            )
                    } else {
                        KFAnimatedImage(URL(string: avatarURL ?? ""))
                            .placeholder(getPlaceholder)
//                            .fade(duration: 0.25)
                            .retry(maxCount: 10)
                    }
                }
                .scaledToFill()
                .frame(width: width, height: height)
                .clipShape(Circle())
                Text(displayName ?? "Sad Panda")
                    .fontWeight(.bold)
                    .font(.largeTitle)
                    .lineLimit(1)
            }
            Spacer()
        }
    }
}

// MARK: MenuRow
private struct MenuRow: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var isPressing = false

    private let isSelected: Bool
    private let symbolName: String
    private let text: String
    private let action: () -> Void

    private var textColor: Color {
        isSelected
            ? .primary
            : (colorScheme == .light
                ? Color(.darkGray)
                : Color(.lightGray))
    }
    private var backgroundColor: Color {
        let color = Color(.systemGray6)

        return isSelected
            ? color
            : (isPressing
                ? color.opacity(0.6)
                : .clear)
    }

    init(
        isSelected: Bool,
        symbolName: String,
        text: String,
        action: @escaping () -> Void
    ) {
        self.isSelected = isSelected
        self.symbolName = symbolName
        self.text = text
        self.action = action
    }

    var body: some View {
        VStack {
            HStack {
                Image(systemName: symbolName)
                    .symbolVariant(isSelected ? .fill : .none)
                    .font(.title).frame(width: 35)
                    .foregroundColor(textColor)
                    .padding(.trailing, 20)
                Text(text.localized)
                    .fontWeight(.medium)
                    .foregroundColor(textColor)
                    .font(.headline)
                Spacer()
            }
            .contentShape(Rectangle())
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(backgroundColor)
            .cornerRadius(10)
            .onTapGesture(perform: action)
            .onLongPressGesture(
                minimumDuration: .infinity,
                maximumDistance: 50,
                pressing: { isPressing = $0 },
                perform: {}
            )
        }
    }
}
