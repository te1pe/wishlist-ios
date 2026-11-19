import UIKit

struct ItemPhoto: Identifiable {
    enum Source {
        case stored(fileName: String)
        case pending(UIImage)
    }

    let id: UUID
    let source: Source

    private init(source: Source) {
        self.id = UUID()
        self.source = source
    }

    static func stored(fileName: String) -> ItemPhoto {
        ItemPhoto(source: .stored(fileName: fileName))
    }

    static func pending(_ image: UIImage) -> ItemPhoto {
        ItemPhoto(source: .pending(image))
    }
}
