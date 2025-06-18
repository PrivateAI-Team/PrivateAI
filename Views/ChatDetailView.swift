
import SwiftUI
import UniformTypeIdentifiers

struct ChatDetailView: View {
    @EnvironmentObject var viewModel: ChatViewModel
    @Environment(\.colorScheme) private var colorScheme
    @State private var input: String = ""
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.messages.isEmpty && !viewModel.isTyping { WelcomeView() }
            else { chatScrollView }
            inputBar
        }
        .background(Theme.secondaryBackgroundColor(for: colorScheme))
        .navigationTitle(viewModel.currentSession?.title ?? "Chat")
        .toolbar {
            Button(role: .destructive) { viewModel.deleteCurrentSession() }
            label: { Label("Excluir Chat", systemImage: "trash") }
            .disabled(viewModel.currentSession == nil)
        }
        .onAppear { isInputFocused = true }
    }

    private var chatScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(viewModel.messages) { msg in MessageBubble(message: msg).id(msg.id) }
                    if viewModel.isTyping { TypingIndicatorView().id("typing-indicator") }
                }
                .padding()
            }
            .animation(.spring(), value: viewModel.messages)
            .onChange(of: viewModel.messages) { _ in
                if let last = viewModel.messages.last {
                    withAnimation(.spring()) { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
            .onChange(of: viewModel.isTyping) { _ in
                if viewModel.isTyping {
                    withAnimation { proxy.scrollTo("typing-indicator", anchor: .bottom) }
                }
            }
        }
    }

    private var inputBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(alignment: .bottom, spacing: 12) {
                Button { selectPDF() } label: { Image(systemName: "doc.badge.plus").font(.title2) }
                    .buttonStyle(.borderless).tint(Color.accentColor).padding(.bottom, 8).help("Enviar PDF")
                Button { selectAudio() } label: { Image(systemName: "waveform.badge.plus").font(.title2) }
                    .buttonStyle(.borderless).tint(Color.accentColor).padding(.bottom, 8).help("Enviar Áudio")
                TextField("Digite sua mensagem…", text: $input, axis: .vertical)
                    .lineLimit(1...5).textFieldStyle(.plain).padding(10)
                    .background(Theme.assistantBubbleColor(for: colorScheme), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .focused($isInputFocused).onSubmit(send)
                Button(action: send) { Image(systemName: "arrow.up.circle.fill").font(.title) }
                    .buttonStyle(.borderless).tint(Color.accentColor)
                    .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0 : 1)
                    .scaleEffect(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.8 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding().background(.bar)
        }
    }

    private func send() {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        input = ""
        Task { await viewModel.send(message: text) }
    }
    private func selectPDF() {
        let panel = NSOpenPanel(); panel.allowedContentTypes = [UTType.pdf]
        panel.begin { resp in
            if resp == .OK, let url = panel.url {
                Task { await viewModel.handlePDF(url: url) }
            }
        }
    }
    private func selectAudio() {
        let panel = NSOpenPanel(); panel.allowedContentTypes = [.audio]
        panel.begin { resp in
            if resp == .OK, let url = panel.url {
                Task { await viewModel.handleAudio(url: url) }
            }
        }
    }
}
