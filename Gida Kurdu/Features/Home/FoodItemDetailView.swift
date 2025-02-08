import SwiftUI
import MapKit

struct FoodItemDetailView: View {
    let item: FoodItem
    @StateObject private var favoriteManager = FavoriteManager.shared
    @State private var region: MKCoordinateRegion
    
    init(item: FoodItem) {
        self.item = item
        let coordinate = CLLocationCoordinate2D(
            latitude: item.location.latitude ?? 41.0082,
            longitude: item.location.longitude ?? 28.9784
        )
        _region = State(initialValue: MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                headerView
                detailCardsView
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                RiskLevelBadge(level: item.riskLevel)
                Spacer()
                Button {
                    favoriteManager.toggleFavorite(for: item.id)
                } label: {
                    Image(systemName: favoriteManager.isFavorite(item.id) ? "heart.fill" : "heart")
                        .font(.title2)
                        .foregroundStyle(favoriteManager.isFavorite(item.id) ? .red : .gray)
                }
                .buttonStyle(.plain)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(item.productName.removingHTMLTags)
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
                
                Text(item.firmName.removingHTMLTags)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                Label(item.formattedDate, systemImage: "calendar")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                StatusBadge(status: item.status)
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        }
        .padding()
    }
    
    private var detailCardsView: some View {
        LazyVStack(spacing: 16) {
            DetailCard(title: "Ürün Detayları") {
                DetailRow(icon: "tag.fill", title: "Marka", value: item.brand.isEmpty ? "Belirtilmemiş" : item.brand.removingHTMLTags)
                DetailRow(icon: "shippingbox.fill", title: "Ürün Grubu", value: item.productGroup.removingHTMLTags)
                if let partyNumber = item.partyNumber {
                    DetailRow(icon: "number", title: "Parti Numarası", value: partyNumber.removingHTMLTags)
                }
            }
            
            if let description = item.productDescription {
                DetailCard(title: "Uygunsuzluk Detayı") {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.title2)
                            .foregroundStyle(.orange)
                        Text(description.removingHTMLTags)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            DetailCard(title: "Konum Bilgileri") {
                DetailRow(icon: "mappin.circle.fill", title: "İl", value: item.location.city.removingHTMLTags)
                if let district = item.location.district {
                    DetailRow(icon: "mappin.and.ellipse", title: "İlçe", value: district.removingHTMLTags)
                }
                
                if let latitude = item.location.latitude,
                   let longitude = item.location.longitude {
                    let coordinate = CLLocationCoordinate2D(
                        latitude: latitude,
                        longitude: longitude
                    )
                    
                    Map(coordinateRegion: .constant(region),
                        annotationItems: [MapLocation(coordinate: coordinate)]) { location in
                        MapAnnotation(coordinate: location.coordinate) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title)
                                .foregroundColor(.red)
                                .background(Circle().fill(.white))
                        }
                    }
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .padding(.top, 8)
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}

private struct MapLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct DetailCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
            content()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        }
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(.blue)
                .frame(width: 24, height: 24)
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .multilineTextAlignment(.trailing)
        }
    }
}

struct StatusBadge: View {
    let status: FoodItem.Status
    
    var color: Color {
        switch status {
        case .active: return .red
        case .resolved: return .green
        case .underInvestigation: return .orange
        }
    }
    
    var text: String {
        switch status {
        case .active: return "Aktif"
        case .resolved: return "Çözüldü"
        case .underInvestigation: return "İncelemede"
        }
    }
    
    var body: some View {
        Text(text)
            .font(.caption.weight(.medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

#Preview {
    NavigationView {
        FoodItemDetailView(item: FoodItem(
            id: "1",
            firmName: "Örnek Firma",
            productName: "Süt Ürünü",
            productDescription: "Bu üründe sağlığa zararlı maddeler tespit edilmiştir. Detaylı inceleme sonucunda ürünün tüketilmemesi gerektiği belirlenmiştir.",
            partyNumber: "123-ABC-456",
            detectionDate: Date(),
            location: Location(
                city: "İstanbul",
                district: "Kadıköy",
                latitude: 40.983013,
                longitude: 29.028783
            ),
            riskLevel: .high,
            status: .active,
            brand: "Test Markası",
            productGroup: "Süt ve Süt Ürünleri"
        ))
    }
} 