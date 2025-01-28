import SwiftUI

struct FoodItemCard: View {
    let item: FoodItem
    @StateObject private var favoriteManager = FavoriteManager.shared
    
    var brandText: String {
        if item.brand.isEmpty || item.brand == "-" {
            return "Belirtilmemiş"
        }
        return item.brand.removingHTMLTags
    }
    
    var productGroupIcon: (name: String, color: Color) {
        switch item.productGroup.lowercased() {
        case let group where group.contains("süt"):
            return ("drop.fill", .blue)
        case let group where group.contains("et"):
            return ("fork.knife", .red)
        case let group where group.contains("balık"):
            return ("fish.fill", .blue)
        case let group where group.contains("tavuk"):
            return ("leaf.fill", .orange)
        case let group where group.contains("yağ"):
            return ("drop.circle.fill", .yellow)
        case let group where group.contains("şeker"):
            return ("cube.fill", .pink)
        case let group where group.contains("baharat"):
            return ("leaf.circle.fill", .green)
        case let group where group.contains("meyve"):
            return ("leaf.arrow.circlepath", .green)
        case let group where group.contains("sebze"):
            return ("leaf", .green)
        case let group where group.contains("içecek"):
            return ("cup.and.saucer.fill", .brown)
        case let group where group.contains("çay"):
            return ("cup.and.saucer.fill", .brown)
        case let group where group.contains("kahve"):
            return ("cup.and.saucer.fill", .brown)
        case let group where group.contains("unlu"):
            return ("birthday.cake.fill", .orange)
        case let group where group.contains("makarna"):
            return ("fork.knife.circle.fill", .orange)
        case let group where group.contains("konserve"):
            return ("shippingbox.fill", .gray)
        case let group where group.contains("dondurma"):
            return ("snowflake", .blue)
        case let group where group.contains("çikolata"):
            return ("square.fill", .brown)
        case let group where group.contains("şekerleme"):
            return ("star.fill", .pink)
        case let group where group.contains("bal"):
            return ("hexagon.fill", .yellow)
        case let group where group.contains("reçel"):
            return ("drop.triangle.fill", .red)
        default:
            return ("circle.grid.cross.fill", .gray)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Üst Kısım: Ürün Grubu, İkon ve Risk Seviyesi
            HStack(spacing: 8) {
                // Ürün Grubu İkonu
                Image(systemName: productGroupIcon.name)
                    .font(.system(size: 16))
                    .foregroundStyle(productGroupIcon.color)
                    .frame(width: 24, height: 24)
                
                Text(item.productGroup.removingHTMLTags)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Spacer()
                
                // Favori Butonu
                Button {
                    favoriteManager.toggleFavorite(for: item.id)
                } label: {
                    Image(systemName: favoriteManager.isFavorite(item.id) ? "heart.fill" : "heart")
                        .font(.system(size: 18))
                        .foregroundStyle(favoriteManager.isFavorite(item.id) ? .red : .gray)
                }
                .buttonStyle(.plain)
                
                RiskLevelBadge(level: item.riskLevel)
            }
            
            // Ürün Adı
            Text(item.productName.removingHTMLTags)
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(1)
                .truncationMode(.tail)
            
            // Uygunsuzluk
            if let description = item.productDescription {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.orange)
                    
                    Text(description.removingHTMLTags)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
            
            // Marka
            HStack(spacing: 4) {
                Image(systemName: "tag.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(.blue)
                
                Text(brandText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
                .padding(.vertical, 4)
            
            // Alt Kısım: Konum ve Tarih
            HStack {
                // İl ve İlçe
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(.red)
                    Text(item.location.city.removingHTMLTags)
                    if let district = item.location.district {
                        Text("/ \(district.removingHTMLTags)")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                
                Spacer()
                
                // Tarih
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                    Text(item.formattedDate)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

struct RiskLevelBadge: View {
    let level: FoodItem.RiskLevel
    
    var color: Color {
        switch level {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(level.description)
                .font(.caption.weight(.medium))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.gradient)
        .clipShape(Capsule())
    }
}

#Preview {
    FoodItemCard(item: FoodItem(
        id: "1",
        firmName: "Test Firma",
        productName: "Test Ürün Adı Çok Uzun Olabilir ve İki Satıra Çıkabilir",
        productDescription: "Bu üründe sağlığa zararlı katkı maddeleri tespit edilmiştir",
        partyNumber: "123",
        detectionDate: Date(),
        location: Location(city: "İstanbul", district: "Kadıköy", latitude: nil, longitude: nil),
        riskLevel: .high,
        status: .active,
        brand: "",
        productGroup: "Süt ve Süt Ürünleri"
    ))
    .padding()
    .background(Color(.systemGroupedBackground))
} 