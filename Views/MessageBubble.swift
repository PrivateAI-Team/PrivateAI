
import SwiftUI

struct MessageBubble: View {
    let message: ChatMessage
    private var isUser: Bool { message.role == .user }
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            if !isUser {
                Image(systemName: "sparkles.circle.fill")
                    .font(.title)
                    .foregroundStyle(Theme.iconColor.opacity(0.8))
            }
            Text(message.text)
                .padding(.horizontal, 16).padding(.vertical, 12)
                .foregroundStyle(isUser ? .white : .primary)
                .background(
                    isUser
                    ? AnyShapeStyle(Theme.userBubbleGradient(for: colorScheme))
                    : AnyShapeStyle(Theme.assistantBubbleColor(for: colorScheme))
                )
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 2)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.borderColor, lineWidth: 1))
                .frame(maxWidth: 450, alignment: isUser ? .trailing : .leading)
                .contextMenu {
                    Button {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(message.text, forType: .string)
                    } label: { Label("Copiar Texto", systemImage: "doc.on.doc") }
                }
            if isUser {
                Image(systemName: "person.crop.circle.fill")
                    .font(.title)
                    .foregroundStyle(Theme.iconColor.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}
