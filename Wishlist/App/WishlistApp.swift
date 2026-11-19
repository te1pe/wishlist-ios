import SwiftUI

@main
struct WishlistApp: App {
    @StateObject private var store = WishlistStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .preferredColorScheme(.light)
        }
    }
}
