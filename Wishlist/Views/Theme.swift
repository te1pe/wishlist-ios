import SwiftUI

enum Theme {
    static let background = Color.white
    static let surface = Color.white
    static let primaryText = Color.black
    static let secondaryText = Color.gray
    static let border = Color.black.opacity(0.08)
    static let shadow = Color.black.opacity(0.04)
    static let accent = Color.black
    static let purchased = Color.green

    static let cardRadius: CGFloat = 24
    static let fieldRadius: CGFloat = 18
    static let controlRadius: CGFloat = 14
    static let thumbnailRadius: CGFloat = 18
}

struct FieldBackground: ViewModifier {
    var cornerRadius: CGFloat = Theme.fieldRadius

    func body(content: Content) -> some View {
        content
            .padding()
            .background(Theme.surface)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Theme.border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

extension View {
    func fieldBackground(cornerRadius: CGFloat = Theme.fieldRadius) -> some View {
        modifier(FieldBackground(cornerRadius: cornerRadius))
    }
}
