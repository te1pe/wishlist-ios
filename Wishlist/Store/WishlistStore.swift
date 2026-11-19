import Combine
import Foundation
import OSLog
import UIKit

@MainActor
final class WishlistStore: ObservableObject {
    @Published private(set) var items: [WishlistItem] = []

    private let itemsURL: URL
    private let imageStore: ImageStore
    private let logger = Logger(subsystem: "com.te1pe.wishlist", category: "WishlistStore")

    init(directory: URL = WishlistStore.defaultDirectory) {
        itemsURL = directory.appendingPathComponent("wishlist_items.json", isDirectory: false)
        imageStore = ImageStore(
            directory: directory.appendingPathComponent("Images", isDirectory: true),
            legacyDirectory: directory
        )
        items = WishlistStore.decodeItems(at: itemsURL)
    }

    func image(named fileName: String) -> UIImage? {
        imageStore.image(named: fileName)
    }

    func photos(for item: WishlistItem) -> [ItemPhoto] {
        item.imageFileNames.map(ItemPhoto.stored(fileName:))
    }

    func addItem(title: String, details: String, price: String, photos: [ItemPhoto]) {
        let item = WishlistItem(
            title: title.trimmed,
            details: details.trimmed,
            price: price.trimmed,
            imageFileNames: imageStore.persist(photos)
        )

        items.insert(item, at: 0)
        save()
    }

    func updateItem(_ item: WishlistItem, title: String, details: String, price: String, photos: [ItemPhoto]) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }

        let previousFileNames = items[index].imageFileNames
        let fileNames = imageStore.persist(photos)

        items[index].title = title.trimmed
        items[index].details = details.trimmed
        items[index].price = price.trimmed
        items[index].imageFileNames = fileNames

        imageStore.delete(fileNames: previousFileNames.filter { !fileNames.contains($0) })
        save()
    }

    func deleteItem(_ item: WishlistItem) {
        items.removeAll { $0.id == item.id }
        imageStore.delete(fileNames: item.imageFileNames)
        save()
    }

    func togglePurchased(_ item: WishlistItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }

        items[index].isPurchased.toggle()
        save()
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(items)
            try data.write(to: itemsURL, options: .atomic)
        } catch {
            logger.error("Не удалось сохранить список: \(error.localizedDescription)")
        }
    }

    private static func decodeItems(at url: URL) -> [WishlistItem] {
        guard let data = try? Data(contentsOf: url) else { return [] }
        guard let items = try? JSONDecoder().decode([WishlistItem].self, from: data) else { return [] }

        return items.sorted { $0.createdAt > $1.createdAt }
    }

    nonisolated static var defaultDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
