import SwiftUI

struct WishlistCardView: View {
    @EnvironmentObject private var store: WishlistStore

    let item: WishlistItem
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onTogglePurchased: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header

            if !item.imageFileNames.isEmpty {
                gallery
            }

            if !item.price.isEmpty {
                Text(item.price)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(Theme.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if !item.details.isEmpty {
                Text(item.details)
                    .font(.body)
                    .foregroundStyle(Theme.primaryText.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(18)
        .background(Theme.surface)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardRadius)
                .stroke(item.isPurchased ? Theme.purchased.opacity(0.45) : Theme.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
        .shadow(color: Theme.shadow, radius: 10, x: 0, y: 4)
        .opacity(item.isPurchased ? 0.88 : 1)
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text(item.displayTitle)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Theme.primaryText)

                if item.isPurchased {
                    Text("Куплено")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Theme.purchased)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Theme.purchased.opacity(0.12))
                        .clipShape(Capsule())
                }
            }

            Spacer()

            Menu {
                Button("Редактировать", action: onEdit)
                Button(
                    item.isPurchased ? "Снять отметку «куплено»" : "Отметить как купленный",
                    action: onTogglePurchased
                )
                Button("Удалить", role: .destructive, action: onDelete)
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title3)
                    .foregroundStyle(Theme.primaryText)
            }
            .accessibilityLabel("Действия с предметом")
        }
    }

    private var gallery: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(item.imageFileNames, id: \.self) { fileName in
                    if let image = store.image(named: fileName) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 220, height: 180)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.thumbnailRadius))
                    }
                }
            }
        }
    }
}
