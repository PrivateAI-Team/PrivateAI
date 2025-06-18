import Foundation
import Speech

struct SpeechService {
    func transcribeAudio(at url: URL) async throws -> String {
        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "pt_BR"))
        guard let recognizer, recognizer.isAvailable else {
            throw NSError(domain: "Speech", code: -1)
        }
        let request = SFSpeechURLRecognitionRequest(url: url)

        return try await withCheckedThrowingContinuation { cont in
            recognizer.recognitionTask(with: request) { result, error in
                if let error { cont.resume(throwing: error) }
                else if let result, result.isFinal {
                    cont.resume(returning: result.bestTranscription.formattedString)
                }
            }
        }
    }
}
