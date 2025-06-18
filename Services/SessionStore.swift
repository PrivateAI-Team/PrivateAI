import Foundation

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

    // MARK: Public
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
