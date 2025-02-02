//
//  GalleryInfosView.swift
//  EhPanda
//
//  Created by 荒木辰造 on 2021/08/15.
//

import SwiftUI
import TTProgressHUD

struct GalleryInfosView: View {
    @State private var hudVisible = false
    @State private var hudConfig = TTProgressHUDConfig()

    private let gallery: Gallery
    private let detail: GalleryDetail

    private var infos: [Info] {
        [
            Info(title: "ID", value: detail.gid),
            Info(title: "Token", value: gallery.token),
            Info(title: "Title", value: detail.title),
            Info(title: "Japanese title", value: detail.jpnTitle),
            Info(title: "Gallery URL", value: gallery.galleryURL),
            Info(title: "Cover URL", value: detail.coverURL),
            Info(title: "Archive URL", value: detail.archiveURL),
            Info(title: "Torrent URL", value: Defaults.URL
                .galleryTorrents(gid: gallery.gid, token: gallery.token)),
            Info(title: "Parent URL", value: detail.parentURL),
            Info(title: "Category", value: detail.category.rawValue.localized),
            Info(title: "Uploader", value: detail.uploader),
            Info(title: "Posted date", value: detail.formattedDateString),
            Info(title: "Visible", value: detail.visibility.value.localized),
            Info(title: "Language", value: detail.language.rawValue.localized),
            Info(title: "Page count", value: String(detail.pageCount)),
            Info(title: "File size", value: String(Int(detail.sizeCount)) + detail.sizeType),
            Info(title: "Favorited times", value: String(detail.favoredCount)),
            Info(title: "Favorited", value: detail.isFavored.yesNoDescription.localized),
            Info(title: "Rating count", value: String(detail.ratingCount)),
            Info(title: "Average rating", value: String(Int(detail.rating))),
            Info(title: "User rating", value:
                detail.userRating == 0 ? nil : String(Int(detail.userRating))),
            Info(title: "Torrent count", value: String(detail.torrentCount))
        ]
    }

    init(gallery: Gallery, detail: GalleryDetail) {
        self.gallery = gallery
        self.detail = detail
    }

    var body: some View {
        ZStack {
            GeometryReader { proxy in
                List(infos) { info in
                    HStack {
                        HStack {
                            Text(info.title.localized)
                            Spacer()
                        }
                        .frame(width: proxy.size.width / 3)
                        Spacer()
                        Button {
                            copy(value: info.value)
                        } label: {
                            Text(info.value ?? "null".localized)
                                .lineLimit(3)
                                .font(.caption)
                                .foregroundStyle(.tint)
                        }
                    }
                }
            }
            TTProgressHUD($hudVisible, config: hudConfig)
        }
        .navigationTitle("Gallery infos")
    }

    private func copy(value: String?) {
        guard let value = value else { return }

        saveToPasteboard(value: value)
        showCopiedHUD()
    }
    private func showCopiedHUD() {
        hudConfig = TTProgressHUDConfig(
            type: .success,
            title: "Success".localized,
            caption: "Copied to clipboard".localized,
            shouldAutoHide: true,
            autoHideInterval: 1
        )
        hudVisible.toggle()
    }
}

private struct Info: Identifiable {
    var id: Int { title.hashValue }
    let title: String
    let value: String?
}

struct GalleryInfosView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GalleryInfosView(gallery: .preview, detail: .preview)
                .preferredColorScheme(.dark)
        }
    }
}
