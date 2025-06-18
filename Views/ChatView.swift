import SwiftUI
import UniformTypeIdentifiers

struct ChatView: View {
    @EnvironmentObject var viewModel: ChatViewModel
    @State private var input: String = ""

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(viewModel.messages) { msg in
                            MessageBubble(message: msg).id(msg.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) { _ in
                    if let last = viewModel.messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }

            Divider()

            HStack {
                Button { selectPDF() } label: {
                    Image(systemName: "doc.badge.plus")
                }.help("Enviar PDF")

                Button { selectAudio() } label: {
                    Image(systemName: "waveform.badge.plus")
                }.help("Enviar Áudio")

                TextField("Digite sua mensagem…", text: $input, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit(send)

                Button("Enviar") { send() }
                    .keyboardShortcut(.return, modifiers: [])
            }
            .padding()
        }
    }

    private func send() {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        Task {
            await viewModel.send(message: text)
            input = ""
        }
    }

    private func selectPDF() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [UTType.pdf]
        panel.begin { resp in
            if resp == .OK, let url = panel.url {
                Task { await viewModel.handlePDF(url: url) }
            }
        }
    }

    private func selectAudio() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.audio]
        panel.begin { resp in
            if resp == .OK, let url = panel.url {
                Task { await viewModel.handleAudio(url: url) }
            }
        }
    }
}
