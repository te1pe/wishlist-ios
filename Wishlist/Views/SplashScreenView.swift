import SwiftUI

struct SplashScreenView: View {
    let onFinish: () -> Void

    @State private var logoScale: CGFloat = 0.86
    @State private var logoOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var visibleCharacters = 0

    private let subtitle = "by te1pe"

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack {
                Spacer()

                Image("WishlistLogo")
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: 220, height: 220)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)

                Spacer()

                Text(String(subtitle.prefix(visibleCharacters)))
                    .font(.system(size: 18))
                    .foregroundStyle(Theme.primaryText.opacity(0.72))
                    .opacity(subtitleOpacity)
                    .padding(.bottom, 72)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Wishlist, \(subtitle)")
        .task {
            await playIntro()
        }
    }

    private func playIntro() async {
        withAnimation(.easeOut(duration: 0.6)) {
            logoOpacity = 1
            logoScale = 1
        }

        try? await Task.sleep(for: .milliseconds(550))

        withAnimation(.easeIn(duration: 0.2)) {
            subtitleOpacity = 1
        }

        for index in 0...subtitle.count {
            visibleCharacters = index
            try? await Task.sleep(for: .milliseconds(30))
        }

        try? await Task.sleep(for: .milliseconds(700))
        onFinish()
    }
}

#Preview {
    SplashScreenView {}
}
