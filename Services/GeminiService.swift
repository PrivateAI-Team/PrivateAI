
import Foundation

actor GeminiService {
    private let session = URLSession(configuration: .ephemeral)

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

    func sendPrompt(history: [ChatMessage],
                    apiKey: String,
                    modelID: String) async throws -> String {

        let contents = history.map {
            Content(role: $0.role == .user ? "user" : "model",
                    parts: [Part(text: $0.text)])
        }
        let body = RequestBody(
            contents: contents,
            generationConfig: .init(
                temperature: 0.7,
                topP: 0.95,
                maxOutputTokens: 4_096)
        )

        let data = try await performRequest(body: body,
                                            apiKey: apiKey,
                                            modelID: modelID)

        let decoded = try JSONDecoder().decode(ResponseBody.self, from: data)
        guard let part = decoded.candidates.first?.content.parts.first else {
            throw URLError(.cannotParseResponse)
        }
        return part.text
    }

    func summarize(history: [ChatMessage],
                   apiKey: String,
                   modelID: String) async throws -> String {

        let snippet = history.prefix(2)
            .map { "\($0.role.rawValue.capitalized): \($0.text)" }
            .joined(separator: "\n\n")

        let prompt = """
        Gere um título curto e conciso em português (máx. 5 palavras) para a conversa.
        Não use aspas.

        CONVERSA:
        \(snippet)

        TÍTULO CONCISO:
        """

        let body = RequestBody(
            contents: [Content(role: "user",
                               parts: [Part(text: prompt)])],
            generationConfig: .init(
                temperature: 0.2,
                topP: 0.95,
                maxOutputTokens: 20)
        )

        let data = try await performRequest(body: body,
                                            apiKey: apiKey,
                                            modelID: modelID)

        let decoded = try JSONDecoder().decode(ResponseBody.self, from: data)
        var summary = decoded.candidates.first?.content.parts.first?.text ?? ""
        summary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
        return summary.isEmpty ? "Chat" : summary
    }

    // MARK: - Networking helper
    private func performRequest(body: RequestBody,
                                apiKey: String,
                                modelID: String) async throws -> Data {

        guard !apiKey.isEmpty else { throw URLError(.userAuthenticationRequired) }

        var url = URL(string:
          "https://generativelanguage.googleapis.com/v1beta/models/\(modelID):generateContent")!
        url.append(queryItems: [.init(name: "key", value: apiKey)])

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(body)

        let (data, resp) = try await session.data(for: req)

        guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
            let body = String(data: data, encoding: .utf8) ?? "Sem detalhes."
            throw URLError(.badServerResponse,
                           userInfo: [NSLocalizedDescriptionKey:
                                      "Servidor: \(body)"])
        }
        return data
    }
}
