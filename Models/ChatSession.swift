
import Foundation

struct ChatSession: Identifiable, Codable, Hashable {
    let id:        UUID
    var title:     String
    let createdAt: Date
    var messages:  [ChatMessage]
}
