import Foundation

actor GeminiService {
    private let apiKey  = "AIzaSyDSzsoIaHbpxOZYwq8OReW7e4pCwY45dk8" // ⚠️ Coloque em Secrets em produção
    private let modelID = "gemini-2.5-flash-preview-05-20"
    private let session = URLSession(configuration: .ephemeral)

    // MARK: Inner types
    struct Part: Codable { let text: String }
    struct Content: Codable { let role: String; let parts: [Part] }
    struct GenerationConfig: Codable {
        let temperature: Double
        let topP: Double
        let maxOutputTokens: Int
    }
    struct RequestBody: Codable {
        let contents: [Content]
        let generationConfig: GenerationConfig
    }
    struct Candidate: Codable { let content: Content }
    struct ResponseBody: Codable { let candidates: [Candidate] }

    // MARK: Public API
    func sendPrompt(history: [ChatMessage]) async throws -> String {
        let contents = history.map {
            Content(role: $0.role == .user ? "user" : "model",
                    parts: [Part(text: $0.text)])
        }

        let body = RequestBody(
            contents: contents,
            generationConfig: .init(temperature: 0.7,
                                    topP: 0.95,
                                    maxOutputTokens: 4_096)
        )

        var url = URL(string:
            "https://generativelanguage.googleapis.com/v1beta/models/\(modelID):generateContent")!
        url.append(queryItems: [URLQueryItem(name: "key", value: apiKey)])

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(ResponseBody.self, from: data)
        guard let part = decoded.candidates.first?.content.parts.first else {
            throw URLError(.cannotParseResponse)
        }
        return part.text
    }
}
