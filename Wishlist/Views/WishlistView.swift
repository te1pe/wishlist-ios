import SwiftUI

struct WishlistView: View {
    @EnvironmentObject private var store: WishlistStore

    @State private var isAddingItem = false
    @State private var editedItem: WishlistItem?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                if store.items.isEmpty {
                    emptyState
                } else {
                    itemList
                }
            }
            .navigationTitle("Wishlist")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isAddingItem = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .accessibilityLabel("Добавить предмет")
                }
            }
            .sheet(isPresented: $isAddingItem) {
                ItemEditorView(mode: .create)
            }
            .sheet(item: $editedItem) { item in
                ItemEditorView(mode: .edit(item))
            }
        }
    }

    private var itemList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(store.items) { item in
                    WishlistCardView(
                        item: item,
                        onEdit: { editedItem = item },
                        onDelete: { store.deleteItem(item) },
                        onTogglePurchased: { store.togglePurchased(item) }
                    )
                }
            }
            .padding()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "gift")
                .font(.system(size: 48))
                .foregroundStyle(Theme.primaryText)

            Text("Пока ничего нет")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Theme.primaryText)

            Text("Нажмите + и добавьте первый предмет в wishlist")
                .font(.body)
                .foregroundStyle(Theme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Button {
                isAddingItem = true
            } label: {
                Text("Добавить предмет")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(Theme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.controlRadius))
            }
        }
        .padding()
    }
}

#Preview {
    WishlistView()
        .environmentObject(WishlistStore())
}
