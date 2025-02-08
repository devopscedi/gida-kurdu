# TestFlight Kurulum Talimatları

## 1. TestFlight Yapılandırması
1. App Store Connect > Gıda Kurdu > TestFlight sekmesine gidin
2. Test Information bölümünü doldurun:
   - Beta App Description: "Gıda Kurdu uygulamasının beta sürümü. Güvenli olmayan gıda ürünlerini takip etmenizi sağlar."
   - Beta App Feedback: [E-posta adresi]
   - Marketing URL: [Web sitesi]
   - Privacy Policy URL: [Gizlilik politikası URL]
   - License Agreement: Varsayılan
   - Beta Build Version: 1.0.0 (1)

## 2. Test Grupları Oluşturma

### İç Test Grubu (Internal Testing)
1. Internal Testing sekmesine gidin
2. Add Internal Testers butonuna tıklayın
3. Test edecek ekip üyelerini ekleyin:
   - Ad Soyad
   - E-posta
   - Rol seçimi

### Harici Test Grubu (External Testing)
1. External Testing sekmesine gidin
2. Create New Group butonuna tıklayın
3. Grup bilgilerini girin:
   - Grup adı: "Beta Testers"
   - Public Link: Aktif
   - Build Distribution: Automatic
4. Add External Testers butonuna tıklayın
5. Test kullanıcılarını ekleyin veya CSV ile toplu ekleyin

## 3. Build Yükleme
1. Xcode'da projeyi açın
2. Scheme'i "Any iOS Device" olarak ayarlayın
3. Product > Archive menüsünü seçin
4. Archive tamamlandığında Distribute App butonuna tıklayın
5. App Store Connect'i seçin
6. Upload'u tamamlayın

## 4. Build Yönetimi
1. Build yüklemesi tamamlandığında App Store Connect'te bekleyin
2. Processing tamamlandığında:
   - Compliance bilgilerini doldurun
   - Test bilgilerini gözden geçirin
   - "Submit to Review" butonuna tıklayın

## 5. Test Davetleri
1. İç test grubu için:
   - Otomatik e-posta gönderilecek
   - TestFlight uygulamasını yüklemeleri gerekiyor
2. Harici test grubu için:
   - Public link'i paylaşın
   - Veya e-posta davetlerini gönderin

## 6. Geri Bildirim Yönetimi
1. TestFlight > Feedback sekmesini takip edin
2. Crash Reports'ı inceleyin
3. Tester yorumlarını değerlendirin
4. Hata raporlarını GitHub Issues'a aktarın 