import Foundation

final class UserPreferencesManager: ObservableObject {
    static let shared = UserPreferencesManager()
    
    @Published var preferences: UserPreferences {
        didSet {
            savePreferences()
        }
    }
    
    private let defaults = UserDefaults.standard
    private let preferencesKey = "userPreferences"
    
    private init() {
        if let data = defaults.data(forKey: preferencesKey),
           let decodedPreferences = try? JSONDecoder().decode(UserPreferences.self, from: data) {
            self.preferences = decodedPreferences
        } else {
            self.preferences = UserPreferences()
        }
    }
    
    private func savePreferences() {
        if let encoded = try? JSONEncoder().encode(preferences) {
            defaults.set(encoded, forKey: preferencesKey)
        }
    }
} 