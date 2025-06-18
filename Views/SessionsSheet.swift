import SwiftUI

struct SessionsSheet: View {
    @EnvironmentObject var viewModel: ChatViewModel
    @Binding var showSheet: Bool

    var body: some View {
        NavigationStack {
            List {
                Section("Chats Anteriores") {
                    ForEach(viewModel.sessions) { session in
                        Button {
                            viewModel.switchTo(sessionID: session.id)
                            showSheet = false
                        } label: {
                            VStack(alignment: .leading) {
                                Text(session.title)
                                Text(session.createdAt, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete { viewModel.deleteSessions(at: $0) }
                }
            }
            .navigationTitle("Histórico")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") { showSheet = false }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button(role: .destructive) {
                        viewModel.deleteAllSessions()
                        showSheet = false
                    } label: {
                        Label("Apagar Tudo", systemImage: "trash.slash")
                    }
                    .disabled(viewModel.sessions.isEmpty)
                }
            }
        }
        .frame(minWidth: 320, minHeight: 450)
    }
}
