# Fal & Astro - Eksikler ve Yapılacaklar

Bu dosya, projenin üretime hazır hale gelmesi için tamamlanması gereken eksikleri listeler.

---

## 🔴 KRİTİK - Üretim İçin Zorunlu

### 1. Yapılandırma Dosyaları

| Dosya | Platform | Açıklama |
|-------|----------|----------|
| `google-services.json` | Android | Firebase yapılandırması - `android/app/` klasörüne |
| `GoogleService-Info.plist` | iOS | Firebase yapılandırması - Xcode'da Runner'a ekle |

**Nasıl Alınır:**
1. [Firebase Console](https://console.firebase.google.com/) > Proje Ayarları > Uygulamalar
2. Her platform için yapılandırma dosyasını indirin

---

### 2. Google OAuth Client ID'leri

**Dosya:** `flutter_app/lib/core/services/social_auth_service.dart`

```dart
// Satır 20-21: Bu değerleri gerçek ID'lerle değiştirin
static const String _webClientId = 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';
static const String _iosClientId = 'YOUR_IOS_CLIENT_ID.apps.googleusercontent.com';
```

**Nasıl Alınır:**
1. [Google Cloud Console](https://console.cloud.google.com/) > APIs & Services > Credentials
2. OAuth 2.0 Client ID oluşturun (Web, iOS, Android için ayrı ayrı)
3. Android için SHA-1 fingerprint gerekli: `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`

---

### 3. In-App Purchase Entegrasyonu

**Dosya:** `flutter_app/lib/data/repositories/subscription_repository.dart`

| Metot | Satır | Durum | Açıklama |
|-------|-------|-------|----------|
| `verifyPurchase()` | 49-65 | STUB | App Store/Play Store makbuz doğrulama |
| `startTrial()` | 68-90 | STUB | Deneme süresi başlatma |
| `cancelSubscription()` | 93-111 | STUB | Abonelik iptal |
| `restorePurchases()` | 114-125 | STUB | Satın alma geri yükleme |

**Yapılacaklar:**
- [ ] App Store Connect'te ürünleri tanımla
- [ ] Google Play Console'da ürünleri tanımla
- [ ] Server-side receipt validation ekle (Supabase Edge Function)
- [ ] `in_app_purchase` paketini gerçek akışla entegre et

---

### 4. Production Ad Unit ID'leri

**Dosya:** `flutter_app/lib/core/services/ad_service.dart`

```dart
// Test ID'leri - Production'da değiştirin
static const String _testRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

// Production ID'lerinizi buraya ekleyin:
// Android: ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX
// iOS: ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX
```

**Nasıl Alınır:**
1. [AdMob Console](https://admob.google.com/)
2. Apps > Add App > Ad Units > Rewarded

---

### 5. Firebase Server Key

**Dosya:** `supabase/functions/send-notification/index.ts`

```bash
# Supabase secrets'a ekleyin
supabase secrets set FIREBASE_SERVER_KEY=your-server-key
```

**Nasıl Alınır:**
1. Firebase Console > Project Settings > Cloud Messaging
2. Server key'i kopyalayın (Legacy mode kullanılıyorsa)
3. Veya FCM v1 API için Service Account JSON kullanın

---

## 🟠 YÜKSEK ÖNCELİK

### 6. FCM Token Backend Sync

**Dosya:** `flutter_app/lib/core/services/push_notification_service.dart`

```dart
// Satır 67: Token yenileme olduğunda backend'e kaydet
// TODO: Update token in backend
```

**Çözüm:** `update_fcm_token` RPC fonksiyonunu çağır

---

### 7. Admin Panel Kullanıcı Listesi

**Dosya:** `flutter_app/lib/presentation/screens/admin/admin_panel_screen.dart`

```dart
// Satır 710-750: Dummy kullanıcı listesi
// Gerçek veritabanı sorgusuyla değiştirilmeli
```

**Yapılacaklar:**
- [ ] `profiles` tablosundan sayfalı kullanıcı listesi çek
- [ ] Arama/filtreleme ekle
- [ ] Kullanıcı detay görüntüleme

---

### 8. ~~Astroloji Hesaplamaları~~ ✅ TAMAMLANDI

**Dosya:** `flutter_app/lib/core/services/astrology_calculator.dart` ve `supabase/functions/_shared/astrology_calculator.ts`

Jean Meeus'un "Astronomical Algorithms" kitabına dayalı offline hesaplama sistemi eklendi:
- ✅ Güneş pozisyonu (güneş burcu)
- ✅ Ay pozisyonu (ay burcu)
- ✅ Ay fazı hesaplama
- ✅ Gezegen pozisyonları (Merkür, Venüs, Mars, Jüpiter, Satürn)
- ✅ Yükselen burç hesaplama (doğum saati ve koordinat gerekli)
- ✅ Natal harita oluşturma
- ✅ Burç uyumu hesaplama

---

## 🟡 ORTA ÖNCELİK

### 9. Offline Mode

**Dosya:** Yeni oluşturulacak

**Yapılacaklar:**
- [ ] Hive ile local cache
- [ ] Son görüntülenen falları kaydet
- [ ] İnternet olmadan cache'den göster
- [ ] Sync mekanizması

---

### 10. Analytics

**Yapılacaklar:**
- [ ] Firebase Analytics entegrasyonu
- [ ] Önemli event'leri logla (fal_created, purchase_completed, vb.)
- [ ] User properties ayarla (subscription_tier, zodiac_sign)

---

### 11. Deep Linking

**Yapılacaklar:**
- [ ] Universal Links (iOS) / App Links (Android) yapılandırması
- [ ] `fal://` custom URL scheme
- [ ] Paylaşılan fal sonuçlarına direkt link

---

## 🟢 DÜŞÜK ÖNCELİK

### 12. Test Coverage

**Dosyalar:**
- `flutter_app/test/repositories/fortune_repository_test.dart` - 2 placeholder test
- `flutter_app/test/providers/auth_provider_test.dart` - 4 placeholder test

**Yapılacaklar:**
- [ ] Auth provider testleri
- [ ] Repository testleri
- [ ] Widget testleri
- [ ] Integration testleri

---

### 13. Yeni Özellikler (Gelecek)

| Özellik | Açıklama |
|---------|----------|
| Tarot Falı | Yeni fal türü |
| El Falı | Palmistry - avuç içi analizi |
| Home Widget | iOS/Android ana ekran widget'ı |
| Apple Watch | Günlük burç widget'ı |
| Çoklu Dil | İngilizce dil desteği |
| Canlı Falcı | Video call ile gerçek falcı |

---

## Durum Özeti

| Kategori | Tamamlanan | Kalan |
|----------|------------|-------|
| Kritik | 0 | 5 |
| Yüksek | 0 | 3 |
| Orta | 0 | 3 |
| Düşük | 0 | 2+ |

---

## Hızlı Başvuru - Komutlar

```bash
# Flutter bağımlılıklarını yükle
cd flutter_app && flutter pub get

# Supabase migrations uygula
supabase db push

# Edge Functions deploy
supabase functions deploy

# Supabase secrets ayarla
supabase secrets set OPENAI_API_KEY=xxx
supabase secrets set FIREBASE_SERVER_KEY=xxx

# Android release build
flutter build appbundle --release

# iOS release build
flutter build ipa --release
```

---

Son güncelleme: 2024-02-02
