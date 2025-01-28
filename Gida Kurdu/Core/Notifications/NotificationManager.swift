import Foundation
import UserNotifications
import CoreLocation

final class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    @Published private(set) var notifications: [FoodNotification] = []
    @Published private(set) var isAuthorized = false
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private let defaults = UserDefaults.standard
    private let notificationsKey = "storedNotifications"
    
    private override init() {
        super.init()
        notificationCenter.delegate = self
        loadStoredNotifications()
        checkAuthorization()
    }
    
    func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            DispatchQueue.main.async {
                self?.isAuthorized = granted
            }
        }
    }
    
    func scheduleNotification(for foodItem: FoodItem) {
        guard isAuthorized else { return }
        
        // Bildirim içeriğini oluştur
        let content = UNMutableNotificationContent()
        content.title = "Yeni Güvenli Olmayan Gıda Bildirimi"
        content.body = "\(foodItem.location.city) bölgesinde \(foodItem.productName) ürünü güvenli olmayan gıda listesine eklendi."
        content.sound = .default
        
        // Bildirim tetikleyicisini oluştur (hemen göster)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        // Bildirim isteğini oluştur
        let request = UNNotificationRequest(
            identifier: "foodAlert-\(foodItem.id)",
            content: content,
            trigger: trigger
        )
        
        // Bildirimi planla
        notificationCenter.add(request) { error in
            if let error = error {
                print("Bildirim planlanırken hata oluştu: \(error.localizedDescription)")
            } else {
                // Bildirimi listeye ekle ve kaydet
                let notification = FoodNotification(
                    id: UUID(),
                    foodItem: foodItem,
                    date: Date(),
                    isRead: false
                )
                DispatchQueue.main.async {
                    self.notifications.insert(notification, at: 0)
                    self.saveNotifications()
                    NotificationCenter.default.post(name: NSNotification.Name("NotificationsDidChange"), object: nil)
                }
            }
        }
    }
    
    func markAsRead(_ notification: FoodNotification) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isRead = true
            saveNotifications()
            NotificationCenter.default.post(name: NSNotification.Name("NotificationsDidChange"), object: nil)
        }
    }
    
    func clearAll() {
        notifications.removeAll()
        saveNotifications()
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
        NotificationCenter.default.post(name: NSNotification.Name("NotificationsDidChange"), object: nil)
    }
    
    private func loadStoredNotifications() {
        if let data = defaults.data(forKey: notificationsKey),
           let decodedNotifications = try? JSONDecoder().decode([FoodNotification].self, from: data) {
            notifications = decodedNotifications
        }
    }
    
    private func saveNotifications() {
        if let encoded = try? JSONEncoder().encode(notifications) {
            defaults.set(encoded, forKey: notificationsKey)
        }
    }
    
    private func checkAuthorization() {
        notificationCenter.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}

struct FoodNotification: Identifiable, Codable {
    let id: UUID
    let foodItem: FoodItem
    let date: Date
    var isRead: Bool
} 