import Foundation
import PDFKit
import UIKit
import CoreLocation

class ReportService {
    static let shared = ReportService()
    
    func generatePDF(session: ScanSession, snapshot: UIImage?) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "HeapScan V2",
            kCGPDFContextAuthor: UserDefaults.standard.string(forKey: "userName") ?? "Unknown Operator"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let path = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("HeapScan_Report_\(Date().timeIntervalSince1970).pdf")
        
        do {
            try renderer.writePDF(to: path, withActions: { context in
                context.beginPage()
                
                let titleAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 24)
                ]
                
                let textAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14)
                ]
                
                "Stockpile Volume Report".draw(at: CGPoint(x: 50, y: 50), withAttributes: titleAttributes)
                
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "ar")
                formatter.dateStyle = .long
                formatter.timeStyle = .short
                let dateString = formatter.string(from: session.timestamp)
                
                var topY: CGFloat = 100
                "Date: \(dateString)".draw(at: CGPoint(x: 50, y: topY), withAttributes: textAttributes)
                topY += 25
                "Operator: \(UserDefaults.standard.string(forKey: "userName") ?? "N/A")".draw(at: CGPoint(x: 50, y: topY), withAttributes: textAttributes)
                topY += 25
                "Location: \(session.location?.coordinate.latitude ?? 0), \(session.location?.coordinate.longitude ?? 0)".draw(at: CGPoint(x: 50, y: topY), withAttributes: textAttributes)
                topY += 25
                "Material Density: \(session.density) tonnes/m³".draw(at: CGPoint(x: 50, y: topY), withAttributes: textAttributes)
                topY += 40
                
                // Measurements
                "Volume: \(String(format: "%.2f", session.measurement?.volume ?? 0)) m³".draw(at: CGPoint(x: 50, y: topY), withAttributes: titleAttributes)
                topY += 30
                let weight = (session.measurement?.volume ?? 0) * session.density
                "Weight: \(String(format: "%.2f", weight)) tonnes".draw(at: CGPoint(x: 50, y: topY), withAttributes: titleAttributes)
                topY += 40
                
                if let snapshot = snapshot {
                    let imageRect = CGRect(x: 50, y: topY, width: pageWidth - 100, height: 300)
                    snapshot.draw(in: imageRect)
                }
            })
            return path
        } catch {
            print("Could not create PDF: \(error)")
            return nil
        }
    }
}
