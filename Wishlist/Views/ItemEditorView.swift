import PhotosUI
import SwiftUI
import UIKit

struct ItemEditorView: View {
    enum Mode {
        case create
        case edit(WishlistItem)

        var title: String {
            switch self {
            case .create: return "Новый предмет"
            case .edit: return "Редактировать"
            }
        }
    }

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: WishlistStore

    let mode: Mode

    @State private var title = ""
    @State private var details = ""
    @State private var price = ""
    @State private var photos: [ItemPhoto] = []
    @State private var pickerSelection: [PhotosPickerItem] = []

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        titleSection
                        photosSection
                        priceSection
                        detailsSection
                    }
                    .padding()
                }
            }
            .navigationTitle(mode.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Отмена") { dismiss() }
                        .foregroundStyle(Theme.primaryText)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Сохранить", action: save)
                        .fontWeight(.semibold)
                        .foregroundStyle(Theme.primaryText)
                        .disabled(!canSave)
                }
            }
            .task(loadExistingItem)
            .onChange(of: pickerSelection) { _, selection in
                importPickedPhotos(selection)
            }
        }
    }

    private var titleSection: some View {
        section("Название") {
            TextField("Например: Sony WH-1000XM5", text: $title)
                .foregroundStyle(Theme.primaryText)
                .fieldBackground(cornerRadius: Theme.fieldRadius - 2)
        }
    }

    private var photosSection: some View {
        section("Фотографии") {
            VStack(alignment: .leading, spacing: 12) {
                PhotosPicker(selection: $pickerSelection, matching: .images) {
                    HStack(spacing: 10) {
                        Image(systemName: "photo.on.rectangle.angled")
                        Text("Добавить фото")
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Theme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.controlRadius))
                }

                if photos.isEmpty {
                    Text("Вы можете добавить сколько угодно фото для одного предмета")
                        .font(.footnote)
                        .foregroundStyle(Theme.secondaryText)
                } else {
                    thumbnails
                }
            }
        }
    }

    private var thumbnails: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(photos) { photo in
                    if let image = resolve(photo) {
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 160, height: 160)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.thumbnailRadius))

                            Button {
                                photos.removeAll { $0.id == photo.id }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.white, Theme.primaryText.opacity(0.7))
                                    .padding(8)
                            }
                            .accessibilityLabel("Удалить фото")
                        }
                    }
                }
            }
        }
    }

    private var priceSection: some View {
        section("Цена") {
            TextField("Например: 25 000 ₽", text: $price)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Theme.primaryText)
                .fieldBackground()
        }
    }

    private var detailsSection: some View {
        section("Описание") {
            TextField("Добавьте описание", text: $details, axis: .vertical)
                .lineLimit(6...12)
                .foregroundStyle(Theme.primaryText)
                .frame(minHeight: 180, alignment: .topLeading)
                .fieldBackground()
        }
    }

    private func section<Content: View>(
        _ heading: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(heading)
                .font(.headline)
                .foregroundStyle(Theme.primaryText)

            content()
        }
    }

    private func resolve(_ photo: ItemPhoto) -> UIImage? {
        switch photo.source {
        case .stored(let fileName): return store.image(named: fileName)
        case .pending(let image): return image
        }
    }

    @Sendable
    private func loadExistingItem() async {
        guard case .edit(let item) = mode else { return }

        title = item.title
        details = item.details
        price = item.price
        photos = store.photos(for: item)
    }

    private func importPickedPhotos(_ selection: [PhotosPickerItem]) {
        guard !selection.isEmpty else { return }

        Task {
            var imported: [ItemPhoto] = []

            for pickerItem in selection {
                guard let data = try? await pickerItem.loadTransferable(type: Data.self),
                      let image = UIImage(data: data) else { continue }

                imported.append(.pending(image))
            }

            photos.append(contentsOf: imported)
            pickerSelection = []
        }
    }

    private func save() {
        switch mode {
        case .create:
            store.addItem(title: title, details: details, price: price, photos: photos)
        case .edit(let item):
            store.updateItem(item, title: title, details: details, price: price, photos: photos)
        }

        dismiss()
    }
}

#Preview {
    ItemEditorView(mode: .create)
        .environmentObject(WishlistStore())
}
