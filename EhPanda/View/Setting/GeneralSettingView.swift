//
//  GeneralSettingView.swift
//  EhPanda
//
//  Created by 荒木辰造 on R 3/01/18.
//

import SwiftUI
import Kingfisher
import LocalAuthentication

struct GeneralSettingView: View, StoreAccessor {
    @EnvironmentObject var store: Store
    @State private var passcodeNotSet = false

    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Language")
                    Spacer()
                    Button(language, action: toSettingLanguage)
                        .foregroundStyle(.tint)
                }
                NavigationLink("Logs", destination: LogsView())
                NavigationLink("Filters", destination: FilterView())
            }
            Section(header: Text("Navigation")) {
                Toggle(
                    "Redirects links to the selected host",
                    isOn: settingBinding.redirectsLinksToSelectedHost
                )
                Toggle(
                    "Detects links from the clipboard",
                    isOn: settingBinding.detectsLinksFromPasteboard
                )
            }
            Section(header: Text("Security")) {
                HStack {
                    Text("Auto-Lock")
                    Spacer()
                    Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.yellow)
                        .opacity((passcodeNotSet && setting.autoLockPolicy != .never) ? 1 : 0)
                    Picker(
                        selection: settingBinding.autoLockPolicy,
                        label: Text(setting.autoLockPolicy.rawValue.localized)
                    ) {
                        ForEach(AutoLockPolicy.allCases) { policy in
                            Text(policy.rawValue.localized).tag(policy)
                        }
                    }
                    .pickerStyle(.menu)
                }
                Toggle(
                    "App switcher blur",
                    isOn: settingBinding.allowsResignActiveBlur
                )
            }
            Section(header: Text("Cache")) {
                Button(action: toggleClearImgCaches) {
                    HStack {
                        Text("Clear image caches")
                        Spacer()
                        Text(setting.diskImageCacheSize)
                            .foregroundStyle(.tint)
                    }
                    .foregroundColor(.primary)
                }
            }
        }
        .onAppear(perform: checkPasscodeExistence)
        .navigationBarTitle("General")
    }
}

private extension GeneralSettingView {
    var settingBinding: Binding<Setting> {
        $store.appState.settings.setting
    }
    var language: String {
        Locale.current.localizedString(
            forLanguageCode: Locale
                .current.languageCode ?? ""
        ) ?? "(null)"
    }

    func checkPasscodeExistence() {
        let context = LAContext()
        var error: NSError?

        if !context.canEvaluatePolicy(
            .deviceOwnerAuthentication,
            error: &error
        ) {
            passcodeNotSet = true
        }
    }

    func toSettingLanguage() {
        if let settingURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingURL, options: [:])
        }
    }

    func toggleClearImgCaches() {
        store.dispatch(.toggleSettingViewActionSheet(state: .clearImgCaches))
    }
}
