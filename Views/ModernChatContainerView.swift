
import SwiftUI

struct ModernChatContainerView: View {
    @EnvironmentObject var viewModel: ChatViewModel
    @AppStorage("appearance") private var appearance: Appearance = .system
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationSplitView {
            SessionsSidebar()
        } detail: {
            if viewModel.currentSessionID != nil {
                ChatDetailView()
            } else {
                WelcomeView()
            }
        }
        .onAppear {
            viewModel.loadSessions()
        }
        .preferredColorScheme(appearance.colorScheme)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: colorScheme)
    }
}
