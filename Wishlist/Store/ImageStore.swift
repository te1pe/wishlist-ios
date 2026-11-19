import OSLog
import UIKit

final class ImageStore {
    private let directory: URL
    private let legacyDirectory: URL
    private let cache = NSCache<NSString, UIImage>()
    private let logger = Logger(subsystem: "com.te1pe.wishlist", category: "ImageStore")

    private let maxDimension: CGFloat = 1600
    private let compressionQuality: CGFloat = 0.85

    init(directory: URL, legacyDirectory: URL) {
        self.directory = directory
        self.legacyDirectory = legacyDirectory
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    func image(named fileName: String) -> UIImage? {
        if let cached = cache.object(forKey: fileName as NSString) {
            return cached
        }

        let candidates = [
            directory.appendingPathComponent(fileName, isDirectory: false),
            legacyDirectory.appendingPathComponent(fileName, isDirectory: false)
        ]

        for url in candidates {
            guard let data = try? Data(contentsOf: url), let image = UIImage(data: data) else { continue }
            cache.setObject(image, forKey: fileName as NSString)
            return image
        }

        return nil
    }

    func persist(_ photos: [ItemPhoto]) -> [String] {
        photos.compactMap { photo in
            switch photo.source {
            case .stored(let fileName):
                return fileName
            case .pending(let image):
                return write(image)
            }
        }
    }

    func delete(fileNames: [String]) {
        for fileName in fileNames {
            cache.removeObject(forKey: fileName as NSString)
            try? FileManager.default.removeItem(at: directory.appendingPathComponent(fileName, isDirectory: false))
            try? FileManager.default.removeItem(at: legacyDirectory.appendingPathComponent(fileName, isDirectory: false))
        }
    }

    private func write(_ image: UIImage) -> String? {
        let resized = downscaled(image)

        guard let data = resized.jpegData(compressionQuality: compressionQuality) else {
            logger.error("Не удалось сжать изображение в JPEG")
            return nil
        }

        let fileName = "\(UUID().uuidString).jpg"

        do {
            try data.write(to: directory.appendingPathComponent(fileName, isDirectory: false), options: .atomic)
            cache.setObject(resized, forKey: fileName as NSString)
            return fileName
        } catch {
            logger.error("Не удалось сохранить изображение: \(error.localizedDescription)")
            return nil
        }
    }

    private func downscaled(_ image: UIImage) -> UIImage {
        let longestSide = max(image.size.width, image.size.height)
        guard longestSide > maxDimension else { return image }

        let ratio = maxDimension / longestSide
        let targetSize = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
        let renderer = UIGraphicsImageRenderer(size: targetSize)

        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
