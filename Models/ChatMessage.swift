
import Foundation

struct ChatMessage: Identifiable, Hashable, Codable {
    enum Role: String, Codable { case user, assistant }
    let id:   UUID
    let role: Role
    let text: String
}
