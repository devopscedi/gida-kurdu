import SwiftUI

struct ContentView: View {
    @StateObject private var preferences = UserPreferencesManager.shared
    
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Ana Sayfa", systemImage: "house")
            }
            .tag(0)
            
            NavigationStack {
                FavoritesView()
            }
            .tabItem {
                Label("Favoriler", systemImage: "heart")
            }
            .tag(1)
            
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Ayarlar", systemImage: "gear")
            }
            .tag(2)
        }
        .preferredColorScheme(preferences.preferences.colorScheme.uiColorScheme)
    }
}

#Preview {
    ContentView()
} 