import SwiftUI

struct RootView: View {
    @State private var isShowingSplash = true

    var body: some View {
        ZStack {
            WishlistView()
                .opacity(isShowingSplash ? 0 : 1)

            if isShowingSplash {
                SplashScreenView {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        isShowingSplash = false
                    }
                }
                .transition(.opacity)
            }
        }
    }
}

#Preview {
    RootView()
        .environmentObject(WishlistStore())
}
