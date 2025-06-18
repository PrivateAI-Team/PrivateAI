import SwiftUI
import Combine
import AVFoundation
import Speech
import PDFKit

@MainActor
final class ChatViewModel: ObservableObject {
    // MARK: Published State
    @Published private(set) var sessions: [ChatSession] = [] {
        didSet { saveSessions() }
    }
    @Published private(set) var currentSessionID: UUID?

    // MARK: Services
    private let gemini      = GeminiService()
    private let recognizer  = SpeechService()
    private let pdfReader   = PDFService()

    // MARK: Computed helpers
    var currentSession: ChatSession? {
        sessions.first { $0.id == currentSessionID }
    }
    var messages: [ChatMessage] {
        get { currentSession?.messages ?? [] }
        set {
            guard let id = currentSessionID,
                  let idx = sessions.firstIndex(where: { $0.id == id }) else { return }
            sessions[idx].messages = newValue
        }
    }

    // MARK: Session Management
    func loadSessions() {
        sessions = SessionStore.shared.load()
        if currentSessionID == nil { currentSessionID = sessions.first?.id }
        if sessions.isEmpty { createNewSession() }
    }

    func createNewSession() {
        let session = ChatSession(id: UUID(), title: "Novo Chat", createdAt: .now, messages: [])
        sessions.insert(session, at: 0)
        currentSessionID = session.id
    }

    func switchTo(sessionID: UUID) { currentSessionID = sessionID }

    func delete(sessionID: UUID) {
        sessions.removeAll { $0.id == sessionID }
        if sessions.isEmpty { createNewSession() }
        else if !sessions.contains(where: { $0.id == currentSessionID }) {
            currentSessionID = sessions.first?.id
        }
    }
    func deleteCurrentSession()          { currentSessionID.map(delete) }
    func deleteAllSessions()             { sessions.removeAll(); createNewSession() }
    func deleteSessions(at offsets: IndexSet) {
        offsets.forEach { delete(sessionID: sessions[$0].id) }
    }

    // MARK: Chat Actions
    func send(message: String) async {
        messages.append(ChatMessage(id: UUID(), role: .user, text: message))
        await pushToGemini()
    }

    private func pushToGemini() async {
        do {
            let reply = try await gemini.sendPrompt(history: messages)
            messages.append(ChatMessage(id: UUID(), role: .assistant, text: reply))
        } catch {
            messages.append(ChatMessage(id: UUID(), role: .assistant,
                                        text: "Erro: \(error.localizedDescription)"))
        }
    }

    // MARK: Media handlers
    func handleAudio(url: URL) async {
        messages.append(ChatMessage(id: UUID(), role: .user,
                                    text: "[Áudio enviado: \(url.lastPathComponent)]"))
        do {
            let text = try await recognizer.transcribeAudio(at: url)
            messages.append(ChatMessage(id: UUID(), role: .assistant,
                                        text: "Transcrição:\n\n" + text))
        } catch {
            messages.append(ChatMessage(id: UUID(), role: .assistant,
                                        text: "Falha na transcrição: \(error.localizedDescription)"))
        }
    }

    func handlePDF(url: URL) async {
        messages.append(ChatMessage(id: UUID(), role: .user,
                                    text: "[PDF enviado: \(url.lastPathComponent)]"))
        do {
            let text = try await pdfReader.extractText(from: url)
            let snippet = String(text.prefix(8_000))
            messages.append(ChatMessage(id: UUID(), role: .user,
                                        text: "Conteúdo do PDF (trecho):\n\n" + snippet))
            await pushToGemini()
        } catch {
            messages.append(ChatMessage(id: UUID(), role: .assistant,
                                        text: "Falha ao ler PDF: \(error.localizedDescription)"))
        }
    }

    // MARK: Persistence
    private func saveSessions() { SessionStore.shared.save(sessions) }
}
