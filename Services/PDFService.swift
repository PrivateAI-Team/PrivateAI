
import PDFKit

struct PDFService {
    func extractText(from url: URL) async throws -> String {
        guard let doc = PDFDocument(url: url) else {
            throw NSError(domain: "PDF", code: -1)
        }
        var out = ""
        for i in 0 ..< doc.pageCount {
            guard
                let page = doc.page(at: i),
                let txt  = page.string
            else { continue }
            out += txt + "\n"
        }
        return out
    }
}
