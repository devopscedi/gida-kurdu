import Foundation
import Combine

final class SettingsViewModel: ObservableObject {
    @Published var preferences: UserPreferences {
        didSet {
            UserPreferencesManager.shared.preferences = preferences
        }
    }
    
    private let notificationManager: NotificationManager
    private var cancellables = Set<AnyCancellable>()
    
    var riskLevels: [FoodItem.RiskLevel] { FoodItem.RiskLevel.allCases }
    var updateFrequencies: [UserPreferences.UpdateFrequency] { UserPreferences.UpdateFrequency.allCases }
    
    init(notificationManager: NotificationManager = .shared) {
        self.notificationManager = notificationManager
        self.preferences = UserPreferencesManager.shared.preferences
        
        setupNotificationObserver()
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default
            .publisher(for: NSNotification.Name("NotificationsDidChange"))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    func requestNotificationPermission() {
        notificationManager.requestAuthorization()
    }
    
    func clearNotifications() {
        // Bildirimleri temizle
        notificationManager.clearAll()
        
        // Bildirim ayarlarını sıfırla
        preferences.notificationsEnabled = false
        preferences.minimumRiskLevel = .low
        preferences.updateFrequency = .hourly
        preferences.selectedCities = []
        
        // UI'ı güncelle
        objectWillChange.send()
    }
} 