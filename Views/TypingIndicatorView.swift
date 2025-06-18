
import SwiftUI

struct TypingIndicatorView: View {
    @State private var scales: [CGFloat] = [0.5, 0.5, 0.5]
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            Image(systemName: "sparkles.circle.fill")
                .font(.title)
                .foregroundStyle(Theme.iconColor.opacity(0.8))
            HStack(spacing: 5) {
                ForEach(0..<3) { i in
                    Circle().frame(width: 8, height: 8).scaleEffect(scales[i])
                        .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true).delay(Double(i) * 0.2), value: scales)
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
            .background(Theme.assistantBubbleColor(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .onAppear { scales = [1.0, 1.0, 1.0] }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
}
