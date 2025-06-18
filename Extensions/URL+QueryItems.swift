import Foundation

extension URL {
    mutating func append(queryItems items: [URLQueryItem]) {
        guard var comps = URLComponents(url: self, resolvingAgainstBaseURL: false) else { return }
        comps.queryItems = (comps.queryItems ?? []) + items
        self = comps.url ?? self
    }
}
