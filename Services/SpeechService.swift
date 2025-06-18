
import AVFoundation
import Speech

struct SpeechService {
    func transcribeAudio(at url: URL) async throws -> String {
        guard
            let recognizer = SFSpeechRecognizer(locale: .init(identifier: "pt_BR")),
            recognizer.isAvailable
        else { throw NSError(domain: "Speech", code: -1) }

        let request = SFSpeechURLRecognitionRequest(url: url)

        return try await withCheckedThrowingContinuation { cont in
            recognizer.recognitionTask(with: request) { res, err in
                if let err { cont.resume(throwing: err) }
                else if let res, res.isFinal {
                    cont.resume(returning: res.bestTranscription.formattedString)
                }
            }
        }
    }
}
