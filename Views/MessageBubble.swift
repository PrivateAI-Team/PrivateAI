import SwiftUI

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .top) {
            if message.role == .assistant {
                Image(systemName: "sparkles").padding(.top, 4)
            }

            Text(message.text)
                .padding(10)
                .background(
                    message.role == .user
                        ? Color.accentColor.opacity(0.15)
                        : Color.gray.opacity(0.15)
                )
                .cornerRadius(8)
                .frame(maxWidth: 350, alignment: message.role == .user ? .trailing : .leading)

            if message.role == .user {
                Image(systemName: "person.crop.circle").padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: message.role == .user ? .trailing : .leading)
    }
}
