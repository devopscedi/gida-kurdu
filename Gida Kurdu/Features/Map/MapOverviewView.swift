import SwiftUI
import MapKit
import CoreLocation

struct MapOverviewView: View {
    @StateObject private var locationManager = LocationManager.shared
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        Group {
            switch locationManager.authorizationStatus {
            case .notDetermined:
                requestLocationView
            case .restricted, .denied:
                locationDisabledView
            case .authorizedWhenInUse, .authorizedAlways:
                mapView
            @unknown default:
                Text("Bilinmeyen konum izni durumu")
            }
        }
        .navigationTitle("Harita")
    }
    
    private var mapView: some View {
        Map(position: .constant(.region(MKCoordinateRegion(
            center: locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )))) {
            // Kullanıcının konumu
            if let location = locationManager.location {
                Marker("Konumunuz", coordinate: location.coordinate)
                    .tint(.blue)
            }
            
            // Gıda ürünleri
            ForEach(viewModel.foodItems) { item in
                if let lat = item.location.latitude,
                   let lon = item.location.longitude {
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    Marker(item.productName, coordinate: coordinate)
                        .tint(markerColor(for: item.riskLevel))
                }
            }
        }
        .onAppear {
            viewModel.fetchItems()
        }
    }
    
    private var requestLocationView: some View {
        VStack(spacing: 16) {
            Image(systemName: "location.circle")
                .font(.system(size: 64))
                .foregroundColor(.blue)
            
            Text("Konum İzni Gerekli")
                .font(.title2)
            
            Text("Yakınınızdaki güvenli olmayan gıdaları görebilmek için konum izni vermeniz gerekmektedir.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button("Konum İzni Ver") {
                locationManager.requestAuthorization()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private var locationDisabledView: some View {
        VStack(spacing: 16) {
            Image(systemName: "location.slash.circle")
                .font(.system(size: 64))
                .foregroundColor(.red)
            
            Text("Konum Erişimi Kapalı")
                .font(.title2)
            
            Text("Yakınınızdaki güvenli olmayan gıdaları görebilmek için Ayarlar'dan konum erişimine izin vermeniz gerekmektedir.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button("Ayarları Aç") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private func markerColor(for riskLevel: FoodItem.RiskLevel) -> Color {
        switch riskLevel {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
}

#Preview {
    MapOverviewView()
} 