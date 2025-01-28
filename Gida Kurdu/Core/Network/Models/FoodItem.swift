import Foundation
import SwiftUI

// MARK: - API Response Models
struct DataTablesResponse: Codable {
    let data: [APIFoodItem]
    let draw: Int
    let recordsTotal: Int
    let recordsFiltered: Int
}

struct APIFoodItem: Codable {
    let duyuruTarihi: String
    let firmaAdi: String
    let marka: String
    let urunAdi: String
    let uygunsuzluk: String
    let partiSeriNo: String
    let firmaIl: String
    let firmaIlce: String
    let urunGrupAdi: String
    
    enum CodingKeys: String, CodingKey {
        case duyuruTarihi = "DuyuruTarihi"
        case firmaAdi = "FirmaAdi"
        case marka = "Marka"
        case urunAdi = "UrunAdi"
        case uygunsuzluk = "Uygunsuzluk"
        case partiSeriNo = "PartiSeriNo"
        case firmaIl = "FirmaIl"
        case firmaIlce = "FirmaIlce"
        case urunGrupAdi = "UrunGrupAdi"
    }
}

// MARK: - Domain Models
struct FoodItem: Codable, Identifiable, Equatable, Hashable {
    let id: String
    let firmName: String
    let productName: String
    let productDescription: String?
    let partyNumber: String?
    let detectionDate: Date
    let location: Location
    var riskLevel: RiskLevel
    let status: Status
    let brand: String
    let productGroup: String
    
    enum RiskLevel: Int, Codable, CaseIterable {
        case low = 0
        case medium = 1
        case high = 2
        
        var description: String {
            switch self {
            case .low:
                return "Düşük"
            case .medium:
                return "Orta"
            case .high:
                return "Yüksek"
            }
        }
        
        var color: Color {
            switch self {
            case .low:
                return .green
            case .medium:
                return .orange
            case .high:
                return .red
            }
        }
    }
    
    enum Status: String, Codable {
        case active
        case resolved
        case underInvestigation
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // MARK: - Equatable
    static func == (lhs: FoodItem, rhs: FoodItem) -> Bool {
        lhs.id == rhs.id
    }
    
    init(from apiItem: APIFoodItem) {
        self.id = apiItem.duyuruTarihi // Tarih bazlı unique ID
        self.firmName = apiItem.firmaAdi
        self.productName = apiItem.urunAdi
        self.productDescription = apiItem.uygunsuzluk
        self.partyNumber = apiItem.partiSeriNo
        self.detectionDate = Self.parseDate(apiItem.duyuruTarihi)
        self.location = Location(
            city: apiItem.firmaIl,
            district: apiItem.firmaIlce,
            latitude: nil,
            longitude: nil
        )
        self.brand = apiItem.marka
        self.productGroup = apiItem.urunGrupAdi
        
        // Risk seviyesini uygunsuzluk metnine göre belirle
        self.riskLevel = Self.determineRiskLevel(from: apiItem.uygunsuzluk)
        self.status = .active // API'den durum bilgisi gelmiyor, varsayılan olarak active
    }
    
    // Preview için constructor
    init(id: String, firmName: String, productName: String, productDescription: String?, partyNumber: String?, detectionDate: Date, location: Location, riskLevel: RiskLevel, status: Status, brand: String = "", productGroup: String = "") {
        self.id = id
        self.firmName = firmName
        self.productName = productName
        self.productDescription = productDescription
        self.partyNumber = partyNumber
        self.detectionDate = detectionDate
        self.location = location
        self.riskLevel = riskLevel
        self.status = status
        self.brand = brand
        self.productGroup = productGroup
    }
    
    private static func parseDate(_ dateString: String) -> Date {
        // API'den gelen tarih formatı: /Date(1234567890000)/
        let pattern = #"\/Date\((\d+)\)\/"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: dateString, range: NSRange(dateString.startIndex..., in: dateString)),
              let range = Range(match.range(at: 1), in: dateString),
              let timestamp = Double(dateString[range]) else {
            return Date()
        }
        
        return Date(timeIntervalSince1970: timestamp / 1000.0)
    }
    
    private static func determineRiskLevel(from description: String) -> RiskLevel {
        let lowercased = description.lowercased()
        
        if lowercased.contains("tehlikeli") || lowercased.contains("zehirli") || lowercased.contains("ölümcül") {
            return .high
        } else if lowercased.contains("risk") || lowercased.contains("zararlı") {
            return .medium
        } else {
            return .low
        }
    }
}

struct Location: Codable, Equatable, Hashable {
    let city: String
    let district: String?
    let latitude: Double?
    let longitude: Double?
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(city)
        hasher.combine(district)
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
    
    // MARK: - Equatable
    static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.city == rhs.city &&
        lhs.district == rhs.district &&
        lhs.latitude == rhs.latitude &&
        lhs.longitude == rhs.longitude
    }
}

// MARK: - Date Formatting
extension FoodItem {
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: detectionDate)
    }
} 