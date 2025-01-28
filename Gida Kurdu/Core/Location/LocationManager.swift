import Foundation
import CoreLocation
import Combine

final class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager()
    
    @Published var location: CLLocation?
    @Published var error: LocationError?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    private let manager = CLLocationManager()
    private var isRequestingAuthorization = false
    
    enum LocationError: Error {
        case unauthorized
        case unableToDetermineLocation
        
        var description: String {
            switch self {
            case .unauthorized:
                return "Konum izni verilmedi. Lütfen ayarlardan konum iznini etkinleştirin."
            case .unableToDetermineLocation:
                return "Konum belirlenemedi. Lütfen internet bağlantınızı kontrol edin."
            }
        }
    }
    
    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 100 // 100 metre
        authorizationStatus = manager.authorizationStatus
    }
    
    func requestAuthorization() {
        guard !isRequestingAuthorization else {
            print("Konum izni zaten isteniyor...")
            return
        }
        
        guard authorizationStatus == .notDetermined else {
            print("Konum izni zaten belirlenmiş: \(authorizationStatus.rawValue)")
            handleAuthorizationStatus(authorizationStatus)
            return
        }
        
        print("Konum izni isteniyor...")
        isRequestingAuthorization = true
        manager.requestWhenInUseAuthorization()
    }
    
    private func handleAuthorizationStatus(_ status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("Konum izni verildi, güncellemeler başlatılıyor...")
            startUpdatingLocation()
        case .denied, .restricted:
            print("Konum izni reddedildi")
            error = .unauthorized
            stopUpdatingLocation()
        case .notDetermined:
            print("Konum izni henüz belirlenmedi")
            // Artık burada requestAuthorization() çağrılmıyor
        @unknown default:
            break
        }
    }
    
    func startUpdatingLocation() {
        print("Konum güncellemeleri başlatılıyor...")
        manager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print("Yeni konum alındı: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        self.location = location
        self.error = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Konum hatası: \(error.localizedDescription)")
        self.error = .unableToDetermineLocation
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("Konum izni durumu değişti: \(manager.authorizationStatus.rawValue)")
        isRequestingAuthorization = false
        authorizationStatus = manager.authorizationStatus
        handleAuthorizationStatus(manager.authorizationStatus)
    }
} 