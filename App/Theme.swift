
import SwiftUI

struct Theme {
    static func userBubbleGradient(for scheme: ColorScheme) -> LinearGradient {
        let colors: [Color] = scheme == .dark ? [.blue, .indigo] : [.accentColor]
        return LinearGradient(colors: colors,
                              startPoint: .topLeading,
                              endPoint: .bottomTrailing)
    }

    static func assistantBubbleColor(for scheme: ColorScheme) -> Color {
        scheme == .dark
        ? Color(nsColor: .textBackgroundColor).opacity(0.8)
        : Color(white: 0.94)
    }

    static func secondaryBackgroundColor(for scheme: ColorScheme) -> Color {
        scheme == .dark
        ? Color(nsColor: .underPageBackgroundColor)
        : Color(hue: 0.1, saturation: 0.02, brightness: 0.98)
    }

    static let iconColor   = Color.secondary
    static let borderColor = Color.gray.opacity(0.2)
    static let welcomeGradient = LinearGradient(
        colors: [Color.black.opacity(0.1), .clear],
        startPoint: .top, endPoint: .bottom
    )
}
