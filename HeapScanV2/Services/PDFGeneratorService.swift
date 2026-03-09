//
//  PDFGeneratorService.swift
//  موثوق رحاب
//

import Foundation
import UIKit

class PDFGeneratorService {
    
    func generatePDF(from photos: [ScanSession]) -> URL? {
        let pageWidth: CGFloat = 595.2   // A4
        let pageHeight: CGFloat = 841.8
        let margin: CGFloat = 40
        let contentWidth = pageWidth - (margin * 2)
        
        let pdfURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("تقرير_موثوق_رحاب_\(dateString()).pdf")
        
        UIGraphicsBeginPDFContextToFile(pdfURL.path, CGRect.zero, [
            kCGPDFContextTitle as String: "تقرير موثوق رحاب" as NSString,
            kCGPDFContextCreator as String: "موثوق رحاب" as NSString
        ])
        
        // Title page
        UIGraphicsBeginPDFPageWithInfo(CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), nil)
        drawTitlePage(width: pageWidth, height: pageHeight, margin: margin, photoCount: photos.count)
        
        // Photo pages
        var y: CGFloat = 0
        var needsNewPage = true
        
        for (index, photo) in photos.enumerated() {
            if needsNewPage {
                UIGraphicsBeginPDFPageWithInfo(CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), nil)
                y = margin
                drawPageHeader(width: pageWidth, margin: margin, y: &y)
                needsNewPage = false
            }
            
            // Photo number
            let numberText = "صورة \(index + 1) من \(photos.count)"
            let numberAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 14),
                .foregroundColor: UIColor(red: 0, green: 0.35, blue: 0.65, alpha: 1)
            ]
            let numberStr = NSAttributedString(string: numberText, attributes: numberAttr)
            numberStr.draw(at: CGPoint(x: margin, y: y))
            y += 25
            
            // Photo
            let maxImageHeight: CGFloat = 280
            let imageSize = photo.image.size
            let scale = min(contentWidth / imageSize.width, maxImageHeight / imageSize.height)
            let scaledWidth = imageSize.width * scale
            let scaledHeight = imageSize.height * scale
            let imageX = margin + (contentWidth - scaledWidth) / 2
            
            photo.image.draw(in: CGRect(x: imageX, y: y, width: scaledWidth, height: scaledHeight))
            y += scaledHeight + 10
            
            // Date
            let infoAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11),
                .foregroundColor: UIColor.darkGray
            ]
            let dateStr = NSAttributedString(string: "التاريخ: \(photo.formattedDate)", attributes: infoAttr)
            dateStr.draw(at: CGPoint(x: margin, y: y))
            y += 18
            
            // Photographer
            let photoStr = NSAttributedString(string: "المصور: \(photo.photographerName)", attributes: infoAttr)
            photoStr.draw(at: CGPoint(x: margin, y: y))
            y += 18
            
            // Location as clickable Google Maps link
            if let loc = photo.location {
                let locURL = "https://maps.google.com/?q=\(loc.latitude),\(loc.longitude)"
                let locAttr: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 11),
                    .foregroundColor: UIColor(red: 0, green: 0.35, blue: 0.65, alpha: 1),
                    .underlineStyle: NSUnderlineStyle.single.rawValue,
                    .link: URL(string: locURL) as Any
                ]
                let locStr = NSAttributedString(string: "الموقع على خرائط Google: \(locURL)", attributes: locAttr)
                locStr.draw(at: CGPoint(x: margin, y: y))
                y += 18
            }
            
            y += 25
            
            // Separator line
            let ctx = UIGraphicsGetCurrentContext()
            ctx?.setStrokeColor(UIColor.lightGray.cgColor)
            ctx?.setLineWidth(0.5)
            ctx?.move(to: CGPoint(x: margin, y: y))
            ctx?.addLine(to: CGPoint(x: pageWidth - margin, y: y))
            ctx?.strokePath()
            y += 15
            
            // Check if we need a new page
            if y > pageHeight - 200 {
                needsNewPage = true
            }
        }
        
        UIGraphicsEndPDFContext()
        return pdfURL
    }
    
    private func drawPageHeader(width: CGFloat, margin: CGFloat, y: inout CGFloat) {
        // Logo on each page (small)
        if let logo = UIImage(named: "V2Logo") {
            let logoHeight: CGFloat = 30
            let logoWidth = logoHeight * (logo.size.width / logo.size.height)
            logo.draw(in: CGRect(x: width - margin - logoWidth, y: y, width: logoWidth, height: logoHeight))
        }
        
        // Page header text
        let headerAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.gray
        ]
        let header = NSAttributedString(string: "تقرير موثوق رحاب", attributes: headerAttr)
        header.draw(at: CGPoint(x: margin, y: y + 10))
        
        y += 45
    }
    
    private func drawTitlePage(width: CGFloat, height: CGFloat, margin: CGFloat, photoCount: Int) {
        let centerX = width / 2
        var y: CGFloat = height * 0.2
        
        // Logo
        if let logo = UIImage(named: "V2Logo") {
            let logoHeight: CGFloat = 100
            let logoWidth = logoHeight * (logo.size.width / logo.size.height)
            logo.draw(in: CGRect(x: centerX - logoWidth / 2, y: y, width: logoWidth, height: logoHeight))
            y += logoHeight + 30
        }
        
        // Title
        let titleAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 32),
            .foregroundColor: UIColor(red: 0, green: 0.35, blue: 0.65, alpha: 1)
        ]
        let title = NSAttributedString(string: "تقرير موثوق رحاب", attributes: titleAttr)
        let titleSize = title.size()
        title.draw(at: CGPoint(x: centerX - titleSize.width / 2, y: y))
        y += 60
        
        // Subtitle
        let subAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18),
            .foregroundColor: UIColor(red: 0.85, green: 0.15, blue: 0.15, alpha: 1)
        ]
        let sub = NSAttributedString(string: "HeapScan V2 Report", attributes: subAttr)
        let subSize = sub.size()
        sub.draw(at: CGPoint(x: centerX - subSize.width / 2, y: y))
        y += 80
        
        // Separator line
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setStrokeColor(UIColor(red: 0, green: 0.35, blue: 0.65, alpha: 1).cgColor)
        ctx?.setLineWidth(2)
        ctx?.move(to: CGPoint(x: margin + 50, y: y))
        ctx?.addLine(to: CGPoint(x: width - margin - 50, y: y))
        ctx?.strokePath()
        y += 40
        
        // Info
        let infoAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.darkGray
        ]
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ar_SA")
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        
        let dateInfo = NSAttributedString(string: "التاريخ: \(formatter.string(from: Date()))", attributes: infoAttr)
        let dateSize = dateInfo.size()
        dateInfo.draw(at: CGPoint(x: centerX - dateSize.width / 2, y: y))
        y += 35
        
        let countInfo = NSAttributedString(string: "عدد الصور: \(photoCount)", attributes: infoAttr)
        let countSize = countInfo.size()
        countInfo.draw(at: CGPoint(x: centerX - countSize.width / 2, y: y))
    }
    
    private func dateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HHmmss"
        return formatter.string(from: Date())
    }
}
