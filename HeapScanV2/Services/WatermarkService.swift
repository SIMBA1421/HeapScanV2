import Foundation
import UIKit
import CoreLocation

class WatermarkService {
    static let shared = WatermarkService()
    
    func addWatermark(to image: UIImage, photographerName: String, date: Date, location: CLLocationCoordinate2D? = nil) -> UIImage? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        
        let renderer = UIGraphicsImageRenderer(size: image.size, format: format)
        
        return renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: image.size))
            
            let fontSize = min(image.size.width, image.size.height) * 0.03
            let padding: CGFloat = 20
            
            // === Company Logo (top-right corner) ===
            if let logo = UIImage(named: "V2Logo") {
                let logoHeight = image.size.height * 0.08
                let logoWidth = logoHeight * (logo.size.width / logo.size.height)
                let logoRect = CGRect(
                    x: image.size.width - logoWidth - padding,
                    y: padding,
                    width: logoWidth,
                    height: logoHeight
                )
                
                // Draw white background behind logo
                let logoBgRect = logoRect.insetBy(dx: -8, dy: -8)
                let logoBgPath = UIBezierPath(roundedRect: logoBgRect, cornerRadius: 8)
                UIColor.white.withAlphaComponent(0.85).setFill()
                logoBgPath.fill()
                
                logo.draw(in: logoRect)
            }
            
            // === Text Watermark (bottom-left) ===
            let shadow = NSShadow()
            shadow.shadowColor = UIColor.black.withAlphaComponent(0.7)
            shadow.shadowOffset = CGSize(width: 1, height: 1)
            shadow.shadowBlurRadius = 2
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            paragraphStyle.baseWritingDirection = .rightToLeft
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: fontSize),
                .foregroundColor: UIColor.white,
                .shadow: shadow,
                .paragraphStyle: paragraphStyle
            ]
            
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ar_SA")
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            let dateString = formatter.string(from: date)
            
            var text = "تصوير: \(photographerName)\nالتاريخ: \(dateString)"
            if let loc = location {
                text += "\nالموقع: \(String(format: "%.5f", loc.latitude)), \(String(format: "%.5f", loc.longitude))"
            }
            
            let attributedText = NSAttributedString(string: text, attributes: attributes)
            
            let textSize = attributedText.boundingRect(
                with: CGSize(width: image.size.width * 0.6, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin],
                context: nil
            ).size
            
            let textRect = CGRect(
                x: padding,
                y: image.size.height - textSize.height - padding,
                width: textSize.width,
                height: textSize.height
            )
            
            let bgRect = textRect.insetBy(dx: -10, dy: -10)
            let bgPath = UIBezierPath(roundedRect: bgRect, cornerRadius: 10)
            UIColor.black.withAlphaComponent(0.5).setFill()
            bgPath.fill()
            
            attributedText.draw(in: textRect)
        }
    }
}
