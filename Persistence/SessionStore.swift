
import Foundation

struct SessionStore {
    static let shared = SessionStore()
    private let fileURL: URL

    private init() {
        let fm    = FileManager.default
        let base  = fm.urls(for: .applicationSupportDirectory,
                            in: .userDomainMask).first!
        let dir   = base.appendingPathComponent("PrivateAI", isDirectory: true)
        try? fm.createDirectory(at: dir,
                                withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("sessions.json")
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
