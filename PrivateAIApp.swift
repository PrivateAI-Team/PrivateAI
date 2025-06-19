import SwiftUI
import Foundation
import Combine
import AVFoundation
import Speech
import PDFKit
import UniformTypeIdentifiers

@main
struct PrivateAIApp: App {
    @StateObject private var viewModel = ChatViewModel()
    @AppStorage("language") private var language: Language = .system

    var body: some Scene {
        WindowGroup {
            ModernChatContainerView()
                .environmentObject(viewModel)
                .environment(\.locale, language.locale ?? .current)
        }
        .windowStyle(.automatic)
        .defaultSize(width: 980, height: 720)
        
        Settings {
            SettingsView()
                .environmentObject(viewModel)
                .environment(\.locale, language.locale ?? .current)
        }
    }
}

enum Language: String, CaseIterable, Identifiable {
    case system, english, spanish, portuguese
    var id: Self { self }

    var displayName: String {
        switch self {
        case .system: String(localized: "language.system")
        case .english: "English"
        case .spanish: "Español"
        case .portuguese: "Português"
        }
    }
    
    var locale: Locale? {
        switch self {
        case .system: nil
        case .english: Locale(identifier: "en")
        case .spanish: Locale(identifier: "es")
        case .portuguese: Locale(identifier: "pt_BR")
        }
    }
}

enum Appearance: String, CaseIterable, Identifiable {
    case light, dark, system
    var id: Self { self }

    var displayName: String {
        switch self {
        case .light: String(localized: "appearance.light")
        case .dark: String(localized: "appearance.dark")
        case .system: String(localized: "appearance.system")
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light: .light
        case .dark: .dark
        case .system: nil
        }
    }
}

struct SettingsView: View {
    @AppStorage("customApiKey") private var customApiKey: String = ""
    @AppStorage("modelID") private var modelID: String = "gemini-2.5-flash"
    @AppStorage("appearance") private var appearance: Appearance = .system
    @AppStorage("language") private var language: Language = .system
    
    @EnvironmentObject var viewModel: ChatViewModel
    
    private let models: [(id: String, displayName: String)] = [
        ("gemini-2.5-flash", "Gemini 2.5 Flash"),
        ("gemini-2.5-pro", "Gemini 2.5 Pro")
    ]
    
    var body: some View {
        Form {
            Section(header: Text("settings.section.authentication")) {
                SecureField("", text: $customApiKey, prompt: Text("settings.apikey.placeholder"))
                    .textFieldStyle(.roundedBorder)
                Text("settings.apikey.caption")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Section(header: Text("settings.section.aimodel")) {
                Picker(selection: $modelID) {
                    ForEach(models, id: \.id) { model in
                        Text(model.displayName).tag(model.id)
                    }
                } label: {
                    Text("Modelos")
                }
                .pickerStyle(.menu)
            }
            
            Section(header: Text("settings.section.appearance")) {
                Picker(selection: $appearance.animation(.easeInOut(duration: 0.4))) {
                    ForEach(Appearance.allCases) { theme in
                        Text(theme.displayName).tag(theme)
                    }
                } label: {
                    Text("settings.appearance.picker")
                }
                .pickerStyle(.segmented)
            }

            Section(header: Text("settings.section.language")) {
                Picker(selection: $language) {
                    ForEach(Language.allCases) { lang in
                        Text(lang.displayName).tag(lang)
                    }
                } label: {
                    Text("settings.language.picker")
                }
                .pickerStyle(.segmented)
                Text("settings.language.caption").font(.caption).foregroundStyle(.secondary)
            }
            
            Section(header: Text("settings.section.data")) {
                Button(role: .destructive) {
                    viewModel.deleteAllSessions()
                } label: {
                    Text("settings.data.delete_history")
                }
            }
        }
        .padding()
        .frame(width: 600, height: 450)
        .navigationTitle(Text("settings.title"))
    }
}

struct Theme {
    static func userBubbleGradient(for scheme: ColorScheme) -> LinearGradient {
        let colors: [Color] = scheme == .dark ? [.blue, .indigo] : [.accentColor]
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    static func assistantBubbleColor(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(nsColor: .textBackgroundColor).opacity(0.8) : Color(white: 0.94)
    }
    
    static func secondaryBackgroundColor(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(nsColor: .underPageBackgroundColor) : Color(hue: 0.1, saturation: 0.02, brightness: 0.98)
    }
    
    static let iconColor = Color.secondary
    static let borderColor = Color.gray.opacity(0.2)
    static let welcomeGradient = LinearGradient(colors: [Color.black.opacity(0.1), Color.clear], startPoint: .top, endPoint: .bottom)
}

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

struct SessionsSidebar: View {
    @EnvironmentObject var viewModel: ChatViewModel
    @Environment(\.locale) private var locale
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
        .searchable(text: $searchText, prompt: Text("sidebar.search.prompt"))
        .safeAreaInset(edge: .bottom) { bottomBar }
        .navigationSplitViewColumnWidth(min: 220, ideal: 250)
        .background(.ultraThinMaterial)
    }
    
    private var bottomBar: some View {
        HStack {
            Button(role: .destructive) { viewModel.deleteAllSessions() }
            label: { Label("sidebar.button.delete_all", systemImage: "trash.slash") }.help("sidebar.button.delete_all.tooltip")
            Spacer()
            Button { viewModel.createNewSession() }
            label: { Label("sidebar.button.new_chat", systemImage: "plus") }.help("sidebar.button.new_chat.tooltip")
        }
        .buttonStyle(.borderless).padding().background(.ultraThinMaterial)
    }
    
    private func formattedSectionHeader(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return String(localized: "date.today") }
        if calendar.isDateInYesterday(date) { return String(localized: "date.yesterday") }
        
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.setLocalizedDateFormatFromTemplate("EEEE, MMMM d")
        return formatter.string(from: date).capitalized
    }
    
    private func deleteItems(at offsets: IndexSet, from section: [ChatSession]) {
        let idsToDelete = offsets.map { section[$0].id }
        viewModel.delete(sessionIDs: idsToDelete)
    }
}

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
        .navigationTitle(viewModel.currentSession?.title ?? String(localized: "chat.default.title"))
        .toolbar {
            Button(role: .destructive) { viewModel.deleteCurrentSession() }
            label: { Label("chat.button.delete", systemImage: "trash") }
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
            .onChange(of: viewModel.messages) { _ in if let last = viewModel.messages.last { withAnimation(.spring()) { proxy.scrollTo(last.id, anchor: .bottom) } } }
            .onChange(of: viewModel.isTyping) { _ in if viewModel.isTyping { withAnimation { proxy.scrollTo("typing-indicator", anchor: .bottom) } } }
        }
    }

    private var inputBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(alignment: .bottom, spacing: 12) {
                Button { selectPDF() } label: { Image(systemName: "doc.badge.plus").font(.title2) }
                    .buttonStyle(.borderless).tint(Color.accentColor).padding(.bottom, 8).help("chat.tooltip.send_pdf")
                Button { selectAudio() } label: { Image(systemName: "waveform.badge.plus").font(.title2) }
                    .buttonStyle(.borderless).tint(Color.accentColor).padding(.bottom, 8).help("chat.tooltip.send_audio")
                TextField("chat.input.placeholder", text: $input, axis: .vertical)
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
    
    private func send() { let text = input.trimmingCharacters(in: .whitespacesAndNewlines); guard !text.isEmpty else { return }; input = ""; Task { await viewModel.send(message: text) } }
    private func selectPDF() { let panel = NSOpenPanel(); panel.allowedContentTypes = [UTType.pdf]; panel.begin { resp in if resp == .OK, let url = panel.url { Task { await viewModel.handlePDF(url: url) } } } }
    private func selectAudio() { let panel = NSOpenPanel(); panel.allowedContentTypes = [.audio]; panel.begin { resp in if resp == .OK, let url = panel.url { Task { await viewModel.handleAudio(url: url) } } } }
}

struct WelcomeView: View {
    @EnvironmentObject var viewModel: ChatViewModel
    
    var body: some View {
        ZStack {
            Theme.welcomeGradient
            VStack {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 80))
                    .foregroundStyle(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                Text("PrivateAI").font(.largeTitle.bold()).padding(.top, 10)
                
                if !viewModel.isApiKeyConfigured {
                    ContentUnavailableView( "welcome.invalid_api.title", systemImage: "key.fill", description: Text("welcome.invalid_api.description") )
                    Button("welcome.button.open_settings") { NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil) }
                } else {
                    Text("welcome.prompt").font(.headline)
                        .foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.horizontal)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct TypingIndicatorView: View {
    @State private var scales: [CGFloat] = [0.5, 0.5, 0.5]
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            Image(systemName: "sparkles.circle.fill")
                .font(.title).foregroundStyle(Theme.iconColor.opacity(0.8))
            HStack(spacing: 5) {
                ForEach(0..<3) { i in
                    Circle().frame(width: 8, height: 8).scaleEffect(scales[i])
                        .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true).delay(Double(i) * 0.2), value: scales)
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
            .background(Theme.assistantBubbleColor(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .onAppear { scales = [1.0, 1.0, 1.0] }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    private var isUser: Bool { message.role == .user }
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            if !isUser { Image(systemName: "sparkles.circle.fill").font(.title).foregroundStyle(Theme.iconColor.opacity(0.8)) }
            Text(message.text)
                .padding(.horizontal, 16).padding(.vertical, 12)
                .foregroundStyle(isUser ? .white : .primary)
                .background(isUser ? AnyShapeStyle(Theme.userBubbleGradient(for: colorScheme)) : AnyShapeStyle(Theme.assistantBubbleColor(for: colorScheme)))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 2)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.borderColor, lineWidth: 1))
                .frame(maxWidth: 450, alignment: isUser ? .trailing : .leading)
                .contextMenu { copyButton }
            if isUser { Image(systemName: "person.crop.circle.fill").font(.title).foregroundStyle(Theme.iconColor.opacity(0.8)) }
        }
        .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    @ViewBuilder private var copyButton: some View { Button { NSPasteboard.general.clearContents(); NSPasteboard.general.setString(message.text, forType: .string) } label: { Label("chat.contextmenu.copy", systemImage: "doc.on.doc") } }
}

struct ChatMessage: Identifiable, Hashable, Codable {
    enum Role: String, Codable { case user, assistant }
    let id: UUID
    let role: Role
    let text: String
}

struct ChatSession: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    let createdAt: Date
    var messages: [ChatMessage]
}

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var sessions: [ChatSession] = [] { didSet { saveSessions() } }
    @Published var currentSessionID: UUID?
    @Published private(set) var isTyping = false
    
    @AppStorage("customApiKey") private var customApiKey: String = ""
    @AppStorage("modelID") private var modelID: String = "gemini-2.5-flash"

    private let gemini = GeminiService()
    private let recognizer = SpeechService()
    private let pdfReader = PDFService()
    private let defaultApiKey = "AIzaSyDSzsoIaHbpxOZYwq8OReW7e4pCwY45dk8"
    
    var effectiveApiKey: String { customApiKey.isEmpty ? defaultApiKey : customApiKey }
    var isApiKeyConfigured: Bool { !effectiveApiKey.isEmpty }

    var currentSession: ChatSession? { sessions.first { $0.id == currentSessionID } }
    var messages: [ChatMessage] { get { currentSession?.messages ?? [] } }
    
    func loadSessions() { sessions = SessionStore.shared.load(); if currentSessionID == nil { currentSessionID = sessions.first?.id } }
    func createNewSession() { let newSession = ChatSession(id: UUID(), title: String(localized: "chat.new.title"), createdAt: .now, messages: []); sessions.insert(newSession, at: 0); currentSessionID = newSession.id }
    func delete(sessionIDs: [UUID]) { let oldID = currentSessionID; sessions.removeAll { sessionIDs.contains($0.id) }; if let oldID = oldID, sessionIDs.contains(oldID) { currentSessionID = sessions.first?.id } }
    func deleteCurrentSession() { if let id = currentSessionID { delete(sessionIDs: [id]) } }
    func deleteAllSessions() { sessions.removeAll(); currentSessionID = nil }

    func send(message: String) async {
        guard isApiKeyConfigured else { handleError(URLError(.userAuthenticationRequired)); return }
        guard let id = currentSessionID, let idx = sessions.firstIndex(where: { $0.id == id }) else { return }
        var updatedSession = sessions[idx]
        updatedSession.messages.append(ChatMessage(id: UUID(), role: .user, text: message))
        sessions[idx] = updatedSession
        await pushToGemini()
    }

    private func pushToGemini() async {
        isTyping = true; defer { isTyping = false }
        do {
            let reply = try await gemini.sendPrompt(history: messages, apiKey: effectiveApiKey, modelID: modelID)
            updateMessages(with: reply)
            if messages.count == 2 { generateTitleForCurrentSession() }
        } catch { handleError(error) }
    }
    
    private func generateTitleForCurrentSession() {
        guard let id = currentSessionID, let idx = sessions.firstIndex(where: { $0.id == id }) else { return }
        let history = sessions[idx].messages
        Task.detached(priority: .background) {
            do {
                let summary = try await self.gemini.summarize(history: history, apiKey: self.effectiveApiKey, modelID: self.modelID)
                await MainActor.run {
                    if let summaryIdx = self.sessions.firstIndex(where: { $0.id == id }) {
                        self.sessions[summaryIdx].title = summary
                    }
                }
            } catch {
                let errorMessage = String(format: NSLocalizedString("error.summary_failed", comment: ""), error.localizedDescription)
                print(errorMessage)
            }
        }
    }
    
    private func updateMessages(with text: String, role: ChatMessage.Role = .assistant) {
        guard let id = currentSessionID, let idx = sessions.firstIndex(where: { $0.id == id }) else { return }
        sessions[idx].messages.append(ChatMessage(id: UUID(), role: role, text: text))
    }
    
    private func handleError(_ error: Error) {
        let errorMessage: String
        if (error as? URLError)?.code == .userAuthenticationRequired {
            errorMessage = String(localized: "error.invalid_api")
        } else { errorMessage = String(format: NSLocalizedString("error.generic", comment: ""), error.localizedDescription) }
        updateMessages(with: errorMessage)
    }

    func handleAudio(url: URL) async {
        guard currentSessionID != nil else { return }
        let userMessage = String(format: NSLocalizedString("chat.audio_sent", comment: ""), url.lastPathComponent)
        updateMessages(with: userMessage, role: .user)
        do {
            let text = try await recognizer.transcribeAudio(at: url)
            let transcriptionMessage = "\(NSLocalizedString("chat.transcription_header", comment: ""))\n\n\(text)"
            updateMessages(with: transcriptionMessage)
        } catch { handleError(error) }
    }

    func handlePDF(url: URL) async {
        guard currentSessionID != nil else { return }
        let userMessage = String(format: NSLocalizedString("chat.pdf_sent", comment: ""), url.lastPathComponent)
        updateMessages(with: userMessage, role: .user)
        do {
            let text = try await pdfReader.extractText(from: url)
            let snippet = String(text.prefix(8000))
            let pdfContentMessage = "\(NSLocalizedString("chat.pdf_snippet_header", comment: ""))\n\n\(snippet)"
            updateMessages(with: pdfContentMessage, role: .user)
            await pushToGemini()
        } catch { handleError(error) }
    }

    private func saveSessions() { SessionStore.shared.save(sessions) }
}

struct SpeechService {
    func transcribeAudio(at url: URL) async throws -> String {
        let recognizer = SFSpeechRecognizer(locale: Locale.current)
        guard let recognizer = recognizer, recognizer.isAvailable else { throw NSError(domain: "Speech", code: -1, userInfo: [NSLocalizedDescriptionKey: "Speech recognizer not available for the current locale."]) }
        let request = SFSpeechURLRecognitionRequest(url: url)
        return try await withCheckedThrowingContinuation { cont in
            recognizer.recognitionTask(with: request) { result, error in
                if let error = error { cont.resume(throwing: error)
                } else if let result = result, result.isFinal { cont.resume(returning: result.bestTranscription.formattedString) }
            }
        }
    }
}

struct PDFService {
    func extractText(from url: URL) async throws -> String {
        guard let doc = PDFDocument(url: url) else { throw NSError(domain: "PDF", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not open PDF document."]) }
        var fullText = ""
        for i in 0..<doc.pageCount {
            guard let page = doc.page(at: i), let text = page.string else { continue }; fullText += text + "\n"
        }
        return fullText
    }
}

struct SessionStore {
    static let shared = SessionStore()
    private let fileURL: URL

    private init() {
        let fm = FileManager.default
        let base = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let folder = base.appendingPathComponent("PrivateAI", isDirectory: true)
        try? fm.createDirectory(at: folder, withIntermediateDirectories: true)
        fileURL = folder.appendingPathComponent("sessions.json")
    }

    func load() -> [ChatSession] {
        guard let data = try? Data(contentsOf: fileURL) else { return [] }
        return (try? JSONDecoder().decode([ChatSession].self, from: data)) ?? []
    }

    func save(_ sessions: [ChatSession]) {
        DispatchQueue.global(qos: .background).async {
            guard let data = try? JSONEncoder().encode(sessions) else { return }
            try? data.write(to: fileURL, options: .atomic)
        }
    }
}

actor GeminiService {
    private let session = URLSession(configuration: .ephemeral)

    struct Part: Codable { let text: String }
    struct Content: Codable { let role: String; let parts: [Part] }
    struct GenerationConfig: Codable { let temperature: Double; let topP: Double; let maxOutputTokens: Int }
    struct RequestBody: Codable { let contents: [Content]; let generationConfig: GenerationConfig }
    struct Candidate: Codable { let content: Content }
    struct ResponseBody: Codable { let candidates: [Candidate] }

    func sendPrompt(history: [ChatMessage], apiKey: String, modelID: String) async throws -> String {
        let contents = history.map { Content(role: $0.role == .user ? "user" : "model", parts: [Part(text: $0.text)]) }
        let body = RequestBody(contents: contents, generationConfig: GenerationConfig(temperature: 0.7, topP: 0.95, maxOutputTokens: 4096))
        let data = try await performRequest(with: body, apiKey: apiKey, modelID: modelID)
        let decoded = try JSONDecoder().decode(ResponseBody.self, from: data)
        guard let part = decoded.candidates.first?.content.parts.first else { throw URLError(.cannotParseResponse) }
        return part.text
    }

    func summarize(history: [ChatMessage], apiKey: String, modelID: String) async throws -> String {
        let conversationText = history.prefix(2).map { "\($0.role.rawValue.capitalized): \($0.text)" }.joined(separator: "\n\n")
        
        let promptFormat = NSLocalizedString("gemini.title_prompt", comment: "Prompt for Gemini to generate a title")
        let prompt = String(format: promptFormat, conversationText)
        
        let promptContent = Content(role: "user", parts: [Part(text: prompt)])
        let body = RequestBody(contents: [promptContent], generationConfig: GenerationConfig(temperature: 0.2, topP: 0.95, maxOutputTokens: 20))
        let data = try await performRequest(with: body, apiKey: apiKey, modelID: modelID)
        let decoded = try JSONDecoder().decode(ResponseBody.self, from: data)
        guard var summary = decoded.candidates.first?.content.parts.first?.text else { throw URLError(.cannotParseResponse) }
        summary = summary.trimmingCharacters(in: .whitespacesAndNewlines.union(CharacterSet(charactersIn: "\"")))
        return summary.isEmpty ? String(localized: "chat.default.title") : summary
    }
    
    private func performRequest(with body: RequestBody, apiKey: String, modelID: String) async throws -> Data {
        guard !apiKey.isEmpty else { throw URLError(.userAuthenticationRequired) }
        var url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(modelID):generateContent")!
        url.append(queryItems: [URLQueryItem(name: "key", value: apiKey)])
        var request = URLRequest(url: url); request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let errorBody = String(data: data, encoding: .utf8) ?? "No error details."
            let errorMessage = String(format: NSLocalizedString("error.server_response", comment: ""), errorBody)
            throw URLError(.badServerResponse, userInfo: [NSLocalizedDescriptionKey: errorMessage])
        }
        return data
    }
}

extension URL {
    mutating func append(queryItems items: [URLQueryItem]) {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return }
        components.queryItems = (components.queryItems ?? []) + items
        self = components.url ?? self
    }
}

#Preview("PrivateAI") {
    ModernChatContainerView()
        .environmentObject(ChatViewModel())
        .environment(\.locale, .init(identifier: "pt_BR"))
}

#Preview("PrivateAI (English)") {
    ModernChatContainerView()
        .environmentObject(ChatViewModel())
        .environment(\.locale, .init(identifier: "en"))
}

#Preview("Settings (English)") {
    SettingsView()
        .environmentObject(ChatViewModel())
        .environment(\.locale, .init(identifier: "en"))
}
