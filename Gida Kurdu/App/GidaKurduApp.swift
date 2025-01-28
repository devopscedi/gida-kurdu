import SwiftUI

@main
struct GidaKurduApp: App {
    @StateObject private var notificationManager = NotificationManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    notificationManager.requestAuthorization()
                }
        }
    }
} 
