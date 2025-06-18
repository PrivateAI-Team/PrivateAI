
import Foundation

extension URL {
    mutating func append(queryItems: [URLQueryItem]) {
        guard var comps = URLComponents(url: self, resolvingAgainstBaseURL: false)
        else { return }
        comps.queryItems = (comps.queryItems ?? []) + queryItems
        self = comps.url ?? self
    }
}
