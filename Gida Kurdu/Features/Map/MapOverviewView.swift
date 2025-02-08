import SwiftUI
import MapKit
import CoreLocation

struct MapOverviewView: View {
    @StateObject private var locationManager = LocationManager.shared
    @StateObject private var viewModel = HomeViewModel()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    private var annotationItems: [MapAnnotationItem] {
        viewModel.foodItems.compactMap { item in
            guard let lat = item.location.latitude,
                  let lon = item.location.longitude else { return nil }
            return MapAnnotationItem(
                id: item.id,
                coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                title: item.productName,
                riskLevel: item.riskLevel
            )
        }
    }
    
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
        Map(coordinateRegion: $region,
            showsUserLocation: true,
            annotationItems: annotationItems) { (item: MapAnnotationItem) in
            MapAnnotation(coordinate: item.coordinate) {
                VStack {
                    Image(systemName: "mappin.circle.fill")
                        .font(.title)
                        .foregroundColor(markerColor(for: item.riskLevel))
                        .background(Circle().fill(.white))
                    
                    Text(item.title)
                        .font(.caption)
                        .padding(4)
                        .background(Color.white)
                        .cornerRadius(4)
                        .shadow(radius: 2)
                }
            }
        }
        .onAppear {
            if let location = locationManager.location {
                region.center = location.coordinate
            }
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

struct MapAnnotationItem: Identifiable {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let title: String
    let riskLevel: FoodItem.RiskLevel
}

#Preview {
    MapOverviewView()
} 