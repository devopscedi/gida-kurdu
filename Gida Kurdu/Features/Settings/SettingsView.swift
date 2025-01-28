import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showingClearConfirmation = false
    
    var body: some View {
        Form {
            Section("Bildirimler") {
                Toggle("Bildirimler", isOn: $viewModel.preferences.notificationsEnabled)
                    .onChange(of: viewModel.preferences.notificationsEnabled) { newValue in
                        if newValue {
                            viewModel.requestNotificationPermission()
                        }
                    }
                
                if viewModel.preferences.notificationsEnabled {
                    Picker("Minimum Risk Seviyesi", selection: $viewModel.preferences.minimumRiskLevel) {
                        ForEach(viewModel.riskLevels, id: \.self) { level in
                            Text(level.description)
                                .tag(level)
                        }
                    }
                    
                    Picker("Güncelleme Sıklığı", selection: $viewModel.preferences.updateFrequency) {
                        ForEach(viewModel.updateFrequencies, id: \.self) { frequency in
                            Text(frequency.description)
                                .tag(frequency)
                        }
                    }
                }
                
                Button(role: .destructive) {
                    showingClearConfirmation = true
                } label: {
                    Text("Bildirimleri Temizle")
                }
            }
            
            Section("Görünüm") {
                Picker("Tema", selection: $viewModel.preferences.colorScheme) {
                    ForEach(UserPreferences.ColorScheme.allCases, id: \.self) { scheme in
                        Text(scheme.description)
                            .tag(scheme)
                    }
                }
            }
            
            Section("Uygulama Hakkında") {
                HStack {
                    Text("Versiyon")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }
                
                Link(destination: URL(string: "https://github.com/yourusername/gida-kurdu")!) {
                    Label("GitHub", systemImage: "link")
                }
            }
            
            Section("Veri ve Gizlilik") {
                Button("Gizlilik Politikası") {
                    // TODO: Show privacy policy
                }
            }
        }
        .navigationTitle("Ayarlar")
        .navigationBarTitleDisplayMode(.large)
        .alert("Bildirimleri Temizle", isPresented: $showingClearConfirmation) {
            Button("İptal", role: .cancel) { }
            Button("Temizle", role: .destructive) {
                viewModel.clearNotifications()
            }
        } message: {
            Text("Tüm bildirimler silinecek. Bu işlem geri alınamaz.")
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
} 