# Sertifika ve Profil Kurulum Talimatları

## 1. Sertifika Oluşturma
1. Apple Developer hesabınıza giriş yapın
2. Certificates, Identifiers & Profiles bölümüne gidin
3. Certificates (+) butonuna tıklayın
4. iOS App Development ve App Store and Ad Hoc seçeneklerini işaretleyin
5. CSR dosyası oluşturun:
   - Keychain Access uygulamasını açın
   - Certificate Assistant > Request a Certificate from a Certificate Authority
   - E-posta adresinizi ve isminizi girin
   - "Saved to disk" seçeneğini işaretleyin
   - CSR dosyasını kaydedin
6. CSR dosyasını Apple Developer sitesine yükleyin
7. Oluşturulan sertifikaları indirin ve çift tıklayarak yükleyin

## 2. App ID Oluşturma
1. Identifiers bölümüne gidin
2. App IDs (+) butonuna tıklayın
3. App seçeneğini işaretleyin
4. Description: Gıda Kurdu
5. Bundle ID: vsdv.Gida-Kurdu
6. Capabilities:
   - Push Notifications
   - Maps
   - Background Modes
   - Associated Domains

## 3. Profil Oluşturma
1. Profiles bölümüne gidin
2. Profiles (+) butonuna tıklayın
3. Development için:
   - iOS App Development seçin
   - Oluşturduğunuz App ID'yi seçin
   - Development sertifikanızı seçin
   - Profili indirin
4. Distribution için:
   - App Store seçin
   - Oluşturduğunuz App ID'yi seçin
   - Distribution sertifikanızı seçin
   - Profili indirin

## 4. Xcode Ayarları
1. Xcode'u açın
2. Gıda Kurdu projesini seçin
3. Signing & Capabilities sekmesine gidin
4. Team seçimini yapın
5. Bundle Identifier'ı kontrol edin
6. Automatically manage signing seçeneğini işaretleyin
7. Profillerin doğru yüklendiğinden emin olun

## 5. App Store Connect Ayarları
1. App Store Connect'e giriş yapın
2. My Apps bölümüne gidin
3. Yeni Uygulama (+) butonuna tıklayın
4. Platfrom: iOS
5. Bundle ID: vsdv.Gida-Kurdu seçin
6. Gerekli bilgileri girin:
   - Ad: Gıda Kurdu - Güvenli Gıda Takibi
   - Dil: Türkçe (Primary)
   - User Access: Full Access
   - SKU: GIDAKURDU2024 