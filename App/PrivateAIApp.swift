import SwiftUI

@main
struct PrivateAIApp: App {
    @StateObject private var viewModel = ChatViewModel()

    var body: some Scene {
        WindowGroup {
            ChatContainerView()
                .environmentObject(viewModel)
        }
        .windowStyle(.automatic)
        .defaultSize(width: 720, height: 860)
    }
}
