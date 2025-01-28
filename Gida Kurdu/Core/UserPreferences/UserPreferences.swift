import Foundation
import SwiftUI

struct UserPreferences: Codable {
    var notificationsEnabled: Bool = false
    var minimumRiskLevel: FoodItem.RiskLevel = .low
    var updateFrequency: UpdateFrequency = .hourly
    var selectedCities: Set<String> = []
    var colorScheme: ColorScheme = .system
    
    static let `default` = UserPreferences()
    
    init(notificationsEnabled: Bool = false,
         minimumRiskLevel: FoodItem.RiskLevel = .low,
         updateFrequency: UpdateFrequency = .hourly,
         selectedCities: Set<String> = [],
         colorScheme: ColorScheme = .system) {
        self.notificationsEnabled = notificationsEnabled
        self.minimumRiskLevel = minimumRiskLevel
        self.updateFrequency = updateFrequency
        self.selectedCities = selectedCities
        self.colorScheme = colorScheme
    }
    
    enum ColorScheme: String, Codable, CaseIterable {
        case system
        case light
        case dark
        
        var description: String {
            switch self {
            case .system:
                return "Sistem"
            case .light:
                return "Açık"
            case .dark:
                return "Koyu"
            }
        }
        
        var uiColorScheme: SwiftUI.ColorScheme? {
            switch self {
            case .system:
                return nil
            case .light:
                return .light
            case .dark:
                return .dark
            }
        }
    }
    
    enum UpdateFrequency: String, Codable, CaseIterable {
        case hourly
        case daily
        case weekly
        
        var description: String {
            switch self {
            case .hourly:
                return "Saatlik"
            case .daily:
                return "Günlük"
            case .weekly:
                return "Haftalık"
            }
        }
        
        var interval: TimeInterval {
            switch self {
            case .hourly:
                return 3600
            case .daily:
                return 86400
            case .weekly:
                return 604800
            }
        }
    }
} 