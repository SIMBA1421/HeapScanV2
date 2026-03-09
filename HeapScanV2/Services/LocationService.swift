import Foundation
import CoreLocation

class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var location: CLLocation?
    @Published var accuracy: CLLocationAccuracy = 0.0
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLoc = locations.last else { return }
        self.location = newLoc
        self.accuracy = newLoc.horizontalAccuracy
    }
    
    var googleMapsLink: String {
        guard let loc = location else { return "" }
        return "https://www.google.com/maps?q=\(loc.coordinate.latitude),\(loc.coordinate.longitude)"
    }
}
