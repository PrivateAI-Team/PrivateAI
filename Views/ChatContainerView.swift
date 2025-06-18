import SwiftUI

struct ChatContainerView: View {
    @EnvironmentObject var viewModel: ChatViewModel
    @State private var showSheet = false

    var body: some View {
        NavigationStack {
            ChatView()
                .navigationTitle(viewModel.currentSession?.title ?? "Novo Chat")
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Button { showSheet = true } label: {
                            Label("Chats", systemImage: "sidebar.left")
                        }.help("Abrir histórico")
                    }
                    ToolbarItemGroup(placement: .primaryAction) {
                        Button { viewModel.createNewSession() } label: {
                            Label("Novo", systemImage: "plus")
                        }
                        Button(role: .destructive) { viewModel.deleteCurrentSession() } label: {
                            Label("Excluir", systemImage: "trash")
                        }
                        .disabled(viewModel.currentSession == nil)
                        Button(role: .destructive) { viewModel.deleteAllSessions() } label: {
                            Label("Apagar Tudo", systemImage: "trash.slash")
                        }
                        .disabled(viewModel.sessions.isEmpty)
                    }
                }
        }
        .sheet(isPresented: $showSheet) {
            SessionsSheet(showSheet: $showSheet)
        }
        .onAppear { viewModel.loadSessions() }
    }
}
