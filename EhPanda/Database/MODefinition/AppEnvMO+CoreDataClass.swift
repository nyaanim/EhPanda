//
//  AppEnvMO+CoreDataClass.swift
//  EhPanda
//
//  Created by 荒木辰造 on R 3/07/10.
//

import CoreData

public class AppEnvMO: NSManagedObject {}

extension AppEnvMO: ManagedObjectProtocol {
    func toEntity() -> AppEnv {
        AppEnv(
            user: user?.toObject() ?? User(),
            filter: filter?.toObject() ?? Filter(),
            setting: setting?.toObject() ?? Setting(),
            tagTranslator: tagTranslator?.toObject() ?? TagTranslator(),
            historyKeywords: historyKeywords?.toObject() ?? [String]()
        )
    }
}

extension AppEnv: ManagedObjectConvertible {
    @discardableResult
    func toManagedObject(in context: NSManagedObjectContext) -> AppEnvMO {
        let appEnvMO = AppEnvMO(context: context)

        appEnvMO.user = user.toData()
        appEnvMO.filter = filter.toData()
        appEnvMO.setting = setting.toData()
        appEnvMO.tagTranslator = tagTranslator.toData()
        appEnvMO.historyKeywords = historyKeywords.toData()

        return appEnvMO
    }
}

struct AppEnv: Codable {
    let user: User
    let filter: Filter
    let setting: Setting
    let tagTranslator: TagTranslator
    let historyKeywords: [String]
}

struct TagTranslator: Codable {
    var language: TranslatableLanguage = .japanese
    var updatedDate: Date = .distantPast
    var contents = [String: String]()

    func translate(text: String) -> String {
        guard let translatedText = contents[text],
              !translatedText.isEmpty
        else { return text }

        return translatedText
    }
}

extension TagTranslator: CustomStringConvertible {
    var description: String {
        "TagTranslator(language: \(language), "
        + "updatedDate: \(updatedDate), "
        + "contents: \(contents.count))"
    }
}
