
import SwiftUI

@main
struct PrivateAIApp: App {
    @StateObject private var viewModel = ChatViewModel()

    var body: some Scene {
        WindowGroup {
            ModernChatContainerView()
                .environmentObject(viewModel)
        }
        .windowStyle(.automatic)
        .defaultSize(width: 980, height: 720)

        Settings {
            SettingsView()
                .environmentObject(viewModel)
        }
    }
}
