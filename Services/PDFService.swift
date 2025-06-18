import Foundation
import PDFKit

struct PDFService {
    func extractText(from url: URL) async throws -> String {
        guard let doc = PDFDocument(url: url) else {
            throw NSError(domain: "PDF", code: -1)
        }
        var fullText = ""
        for i in 0..<doc.pageCount {
            guard let page = doc.page(at: i),
                  let text = page.string else { continue }
            fullText += text + "\n"
        }
        return fullText
    }
}
