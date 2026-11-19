import Foundation

struct WishlistItem: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var details: String
    var price: String
    var imageFileNames: [String]
    var isPurchased: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String = "",
        details: String = "",
        price: String = "",
        imageFileNames: [String] = [],
        isPurchased: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.details = details
        self.price = price
        self.imageFileNames = imageFileNames
        self.isPurchased = isPurchased
        self.createdAt = createdAt
    }

    var displayTitle: String {
        title.isEmpty ? "Без названия" : title
    }
}
