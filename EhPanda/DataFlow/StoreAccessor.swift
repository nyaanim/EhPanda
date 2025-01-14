//
//  StoreAccessor.swift
//  EhPanda
//
//  Created by 荒木辰造 on R 3/05/04.
//

import SwiftUI
import Combine

protocol StoreAccessor {
    var store: Store { get }
}

// MARK: AppState
extension StoreAccessor {
    var appState: AppState {
        store.appState
    }
    var environment: AppState.Environment {
        appState.environment
    }
    var settings: AppState.Settings {
        appState.settings
    }
    var homeInfo: AppState.HomeInfo {
        appState.homeInfo
    }
    var detailInfo: AppState.DetailInfo {
        appState.detailInfo
    }
    var contentInfo: AppState.ContentInfo {
        appState.contentInfo
    }
}

// MARK: Environment
extension StoreAccessor {
    var isAppUnlocked: Bool {
        environment.isAppUnlocked
    }
    var isSlideMenuClosed: Bool {
        environment.isSlideMenuClosed
    }
    var homeListType: HomeListType {
        environment.homeListType
    }
    var viewControllersCount: Int {
        environment.viewControllersCount
    }
}

// MARK: Settings
extension StoreAccessor {
    var user: User {
        settings.user
    }
    var currentGP: String? {
        user.currentGP
    }
    var currentCredits: String? {
        user.currentCredits
    }
    var favoriteNames: [Int: String]? {
        user.favoriteNames
    }
    var setting: Setting {
        settings.setting
    }
    var filter: Filter {
        settings.filter
    }
    var accentColor: Color {
        setting.accentColor
    }
    var allowsResignActiveBlur: Bool {
        setting.allowsResignActiveBlur
    }
    var autoLockPolicy: AutoLockPolicy {
        setting.autoLockPolicy
    }
    var detectsLinksFromPasteboard: Bool {
        setting.detectsLinksFromPasteboard
    }
}
