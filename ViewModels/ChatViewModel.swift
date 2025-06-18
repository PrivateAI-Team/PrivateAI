
import SwiftUI
import Combine
import UniformTypeIdentifiers

@MainActor
final class ChatViewModel: ObservableObject {
    // Published
    @Published var sessions: [ChatSession] = [] { didSet { saveSessions() } }
    @Published var currentSessionID: UUID?
    @Published private(set) var isTyping = false

    // User defaults
    @AppStorage("customApiKey") private var customApiKey: String = ""
    @AppStorage("modelID")     private var modelID: String     = "gemini-1.5-flash-latest"

    // Services
    private let gemini     = GeminiService()
    private let recognizer = SpeechService()
    private let pdfReader  = PDFService()
    private let defaultApiKey = "AIzaSyDSzsoIaHbpxOZYwq8OReW7e4pCwY45dk8"

    // Helpers
    var effectiveApiKey: String { customApiKey.isEmpty ? defaultApiKey : customApiKey }
    var isApiKeyConfigured: Bool { !effectiveApiKey.isEmpty }
    var currentSession: ChatSession? { sessions.first { $0.id == currentSessionID } }
    var messages: [ChatMessage] { currentSession?.messages ?? [] }

    // Session management
    func loadSessions() {
        sessions = SessionStore.shared.load()
        if currentSessionID == nil { currentSessionID = sessions.first?.id }
    }

    func createNewSession() {
        let newSession = ChatSession(id: UUID(),
                                     title: "Novo Chat",
                                     createdAt: .now,
                                     messages: [])
        sessions.insert(newSession, at: 0)
        currentSessionID = newSession.id
    }

    func delete(sessionIDs: [UUID]) {
        let oldID = currentSessionID
        sessions.removeAll { sessionIDs.contains($0.id) }
        if let oldID, sessionIDs.contains(oldID) {
            currentSessionID = sessions.first?.id
        }
    }

    func deleteCurrentSession() { if let id = currentSessionID { delete(sessionIDs: [id]) } }
    func deleteAllSessions() { sessions.removeAll(); currentSessionID = nil }

    // User action
    func send(message: String) async {
        guard isApiKeyConfigured else {
            handleError(URLError(.userAuthenticationRequired))
            return
        }
        guard let id = currentSessionID,
              let idx = sessions.firstIndex(where: { $0.id == id }) else { return }

        sessions[idx].messages.append(ChatMessage(id: .init(), role: .user, text: message))
        await pushToGemini()
    }

    func handleAudio(url: URL) async {
        updateMessages(with: "[Áudio enviado: \(url.lastPathComponent)]", role: .user)
        do {
            let text = try await recognizer.transcribeAudio(at: url)
            updateMessages(with: "Transcrição:\n\n" + text)
        } catch { handleError(error) }
    }

    func handlePDF(url: URL) async {
        updateMessages(with: "[PDF enviado: \(url.lastPathComponent)]", role: .user)
        do {
            let text = try await pdfReader.extractText(from: url)
            let snippet = String(text.prefix(8_000))
            updateMessages(with: "Conteúdo do PDF (trecho):\n\n" + snippet, role: .user)
            await pushToGemini()
        } catch { handleError(error) }
    }

    // Helpers
    private func pushToGemini() async {
        isTyping = true
        defer { isTyping = false }

        do {
            let reply = try await gemini.sendPrompt(history: messages,
                                                    apiKey: effectiveApiKey,
                                                    modelID: modelID)
            updateMessages(with: reply)
            if messages.count == 2 { generateTitleForCurrentSession() }
        } catch { handleError(error) }
    }

    private func generateTitleForCurrentSession() {
        guard let id = currentSessionID,
              let idx = sessions.firstIndex(where: { $0.id == id }) else { return }
        let history = sessions[idx].messages

        Task.detached(priority: .background) { [self] in
            do {
                let summary = try await gemini.summarize(history: history,
                                                          apiKey: effectiveApiKey,
                                                          modelID: modelID)
                await MainActor.run {
                    if let i = sessions.firstIndex(where: { $0.id == id }) {
                        sessions[i].title = summary
                    }
                }
            } catch {
                print("Falha ao gerar resumo: \(error)")
            }
        }
    }

    private func updateMessages(with text: String, role: ChatMessage.Role = .assistant) {
        guard let id = currentSessionID,
              let idx = sessions.firstIndex(where: { $0.id == id }) else { return }
        sessions[idx].messages.append(ChatMessage(id: .init(), role: role, text: text))
    }

    private func handleError(_ error: Error) {
        let msg: String
        if (error as? URLError)?.code == .userAuthenticationRequired {
            msg = "Erro: Chave de API inválida ou não configurada. Verifique Ajustes."
        } else { msg = "Erro: \(error.localizedDescription)" }
        updateMessages(with: msg)
    }

    private func saveSessions() { SessionStore.shared.save(sessions) }
}
