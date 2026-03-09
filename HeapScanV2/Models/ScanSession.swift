import SwiftUI
import CoreLocation

struct ScanSession: Identifiable, Codable {
    var id: UUID = UUID()
    var date: Date = Date()
    var operatorName: String
    var location: CLLocationCoordinate2D?
    var volume: Double
    var weight: Double
    var pdfReportURL: URL?
    
    enum CodingKeys: String, CodingKey {
        case id, date, operatorName, location, volume, weight, pdfReportURL
    }
    
    init(operatorName: String, location: CLLocationCoordinate2D?, volume: Double, weight: Double) {
        self.operatorName = operatorName
        self.location = location
        self.volume = volume
        self.weight = weight
    }

    // Boilerplate codable extensions for CLLocationCoordinate2D
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        operatorName = try container.decode(String.self, forKey: .operatorName)
        volume = try container.decode(Double.self, forKey: .volume)
        weight = try container.decode(Double.self, forKey: .weight)
        pdfReportURL = try container.decode(URL?.self, forKey: .pdfReportURL)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(operatorName, forKey: .operatorName)
        try container.encode(volume, forKey: .volume)
        try container.encode(weight, forKey: .weight)
        try container.encode(pdfReportURL, forKey: .pdfReportURL)
    }
}
