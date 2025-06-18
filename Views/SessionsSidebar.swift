
import SwiftUI

struct SessionsSidebar: View {
    @EnvironmentObject var viewModel: ChatViewModel
    @State private var searchText = ""
    @State private var itemHovering: UUID?

    private var filteredSessions: [ChatSession] {
        if searchText.isEmpty { return viewModel.sessions }
        else { return viewModel.sessions.filter { $0.title.localizedCaseInsensitiveContains(searchText) } }
    }

    private var groupedSessions: [Date: [ChatSession]] {
        Dictionary(grouping: filteredSessions) { session in Calendar.current.startOfDay(for: session.createdAt) }
    }

    private var sortedGroupKeys: [Date] {
        groupedSessions.keys.sorted(by: >)
    }

    var body: some View {
        List(selection: $viewModel.currentSessionID) {
            ForEach(sortedGroupKeys, id: \.self) { date in
                Section(header: Text(formattedSectionHeader(for: date))) {
                    ForEach(groupedSessions[date]!) { session in
                        Text(session.title)
                            .padding(.vertical, 6).listRowSeparator(.hidden)
                            .contentShape(Rectangle())
                            .background(itemHovering == session.id ? Color.gray.opacity(0.2) : Color.clear)
                            .cornerRadius(6)
                            .onHover { isHovering in itemHovering = isHovering ? session.id : nil }
                            .tag(session.id)
                    }
                    .onDelete { indexSet in deleteItems(at: indexSet, from: groupedSessions[date]!) }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Pesquisar Chats")
        .safeAreaInset(edge: .bottom) { bottomBar }
        .navigationSplitViewColumnWidth(min: 220, ideal: 250)
        .background(.ultraThinMaterial)
    }

    private var bottomBar: some View {
        HStack {
            Button(role: .destructive) { viewModel.deleteAllSessions() }
            label: { Label("Apagar Tudo", systemImage: "trash.slash") }.help("Apagar todo o histórico")
            Spacer()
            Button { viewModel.createNewSession() }
            label: { Label("Novo Chat", systemImage: "plus") }.help("Criar um novo chat")
        }
        .buttonStyle(.borderless).padding().background(.ultraThinMaterial)
    }

    private func formattedSectionHeader(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Hoje" }
        else if calendar.isDateInYesterday(date) { return "Ontem" }
        else {
            let formatter = DateFormatter(); formatter.locale = Locale(identifier: "pt_BR"); formatter.dateFormat = "EEEE, d 'de' MMMM"
            return formatter.string(from: date).capitalized
        }
    }

    private func deleteItems(at offsets: IndexSet, from section: [ChatSession]) {
        let idsToDelete = offsets.map { section[$0].id }
        viewModel.delete(sessionIDs: idsToDelete)
    }
}
