# Fal & Astro - V2 Ultimate

Kahve falı, rüya yorumu ve kişiye özel astroloji uygulaması. Flutter + Supabase ile geliştirilmiş "Self-Running Mystic Super App".

---

## V2 Özellikler Durumu

### Ana Özellikler

| Özellik | Durum | Açıklama |
|---------|-------|----------|
| Kahve Falı | ✅ Tamamlandı | Fincan/tabak fotoğrafı, AI yorum, sembol tanıma |
| Rüya Yorumu | ✅ Tamamlandı | Metin/sesli giriş, sembol analizi, şanslı sayılar |
| Günlük Burç | ✅ Tamamlandı | 12 burç için otomatik günlük yorumlar |
| Astroloji Raporu | ✅ Tamamlandı | Natal, haftalık, aylık, yıllık raporlar |
| Burç Uyumu (Synastry) | ✅ Tamamlandı | İki burç arasında uyum analizi |

### UI/UX Özellikleri

| Özellik | Durum | Açıklama |
|---------|-------|----------|
| 5 Tab Navigasyon | ✅ Tamamlandı | Ana Sayfa, Fal, Rüya, Astro, Profil |
| Mistik Yükleme Animasyonu | ✅ Tamamlandı | Dönen semboller, değişen mesajlar (min 5sn) |
| Sesli Giriş | ✅ Tamamlandı | Rüya anlatımı için Türkçe ses tanıma |
| Instagram Stories Paylaşım | ✅ Tamamlandı | Sonuçları hikaye olarak paylaşma |
| Dark/Light Tema | ✅ Tamamlandı | Material 3 tema desteği |

### Oyunlaştırma (Gamification)

| Özellik | Durum | Açıklama |
|---------|-------|----------|
| Kredi Sistemi | ✅ Tamamlandı | Her işlem için kredi kullanımı |
| Başarımlar (Achievements) | ✅ Tamamlandı | Rozetler ve XP sistemi |
| Günlük Seri (Streak) | ✅ Tamamlandı | Ardışık giriş takibi |
| Seviye Sistemi | ✅ Tamamlandı | XP ile seviye atlama |
| Kredi Mağazası | ✅ Tamamlandı | Kredi paketleri satın alma |

### Monetizasyon

| Özellik | Durum | Açıklama |
|---------|-------|----------|
| Google Rewarded Ads | ✅ Tamamlandı | Reklam izleyerek kredi kazanma (günde max 5) |
| Kredi Paketleri | ✅ Tamamlandı | TRY/USD fiyatlı paketler |
| In-App Purchase | ⚠️ Stub | IAP entegrasyonu yapılacak |

### Kimlik Doğrulama

| Özellik | Durum | Açıklama |
|---------|-------|----------|
| E-posta Giriş | ✅ Tamamlandı | E-posta/şifre ile kayıt ve giriş |
| Google Sign In | ✅ Tamamlandı | Google OAuth ile hızlı giriş (Android/iOS) |
| Apple Sign In | ✅ Tamamlandı | Apple ID ile giriş (iOS için zorunlu) |

### Bildirimler

| Özellik | Durum | Açıklama |
|---------|-------|----------|
| Push Notifications | ✅ Tamamlandı | Firebase Cloud Messaging (FCM) |
| Admin Bildirim Gönderimi | ✅ Tamamlandı | Admin panelden toplu bildirim |
| Topic Aboneliği | ✅ Tamamlandı | Konuya göre bildirim (burç, promosyon vb.) |
| Yerel Bildirimler | ✅ Tamamlandı | Günlük hatırlatmalar |

### Yasal Uyumluluk

| Özellik | Durum | Açıklama |
|---------|-------|----------|
| GDPR/KVKK Onay Dialogu | ✅ Tamamlandı | Zorunlu onay ve audit log |
| Gizlilik Politikası | ✅ Tamamlandı | Uygulama içi erişim |
| Kullanım Şartları | ✅ Tamamlandı | Uygulama içi erişim |
| Yasal Uyarılar | ✅ Tamamlandı | "Eğlence amaçlıdır" bildirimi |

### Backend & Edge Functions

| Özellik | Durum | Açıklama |
|---------|-------|----------|
| fortune_read | ✅ Tamamlandı | Kahve falı API |
| dream-interpret | ✅ Tamamlandı | Rüya yorumu API |
| cron-daily-generator | ✅ Tamamlandı | Otomatik günlük burç üretimi |
| synastry-calculate | ✅ Tamamlandı | Burç uyumu hesaplama |
| daily_astro | ✅ Tamamlandı | Günlük astroloji |
| astro_report | ✅ Tamamlandı | Astroloji raporları |
| send-notification | ✅ Tamamlandı | FCM push bildirim gönderimi |

### Admin & Yönetim

| Özellik | Durum | Açıklama |
|---------|-------|----------|
| Admin Panel | ✅ Tamamlandı | İstatistikler, kullanıcı yönetimi |
| Günlük Burç Tetikleme | ✅ Tamamlandı | Manuel cron tetikleme |
| Kullanıcı İstatistikleri | ✅ Tamamlandı | Toplam kullanıcı, aktif, fal sayısı |
| Toplu Bildirim Gönderimi | ✅ Tamamlandı | Admin'den tüm kullanıcılara FCM bildirimi |

---

## Yapılacaklar (TODO)

### Yüksek Öncelik
- [ ] **In-App Purchase Entegrasyonu** - Gerçek ödeme sistemi
- [ ] **Production Ad Unit IDs** - Gerçek reklam ID'leri
- [ ] **Firebase Yapılandırması** - `google-services.json` ve `GoogleService-Info.plist`
- [ ] **Google OAuth Client IDs** - Google Cloud Console'da üretim ID'leri

### Orta Öncelik
- [ ] **Offline Mode** - Hive ile local cache
- [ ] **Widget Desteği** - iOS/Android home screen widget
- [ ] **Apple Watch App** - Günlük burç widget'ı
- [ ] **Derin Bağlantılar** - Deep linking
- [ ] **Analytics** - Firebase Analytics / Mixpanel

### Düşük Öncelik
- [ ] **Çoklu Dil** - İngilizce dil desteği
- [ ] **Tarot Falı** - Yeni fal türü
- [ ] **El Falı** - Palmistry
- [ ] **Canlı Falcı** - Video call ile gerçek falcı
- [ ] **Sosyal Özellikler** - Arkadaş ekleme, paylaşım

---

## Teknik Detaylar

### Kullanılan Teknolojiler

**Frontend:**
- Flutter 3.2+
- Riverpod (State Management)
- GoRouter (Navigation)
- Material 3 (UI)
- google_mobile_ads (Reklamlar)
- speech_to_text (Sesli giriş)
- share_plus (Paylaşım)
- google_sign_in (Google OAuth)
- sign_in_with_apple (Apple OAuth)
- firebase_core & firebase_messaging (Push Notifications)
- video_player (Login arkaplan videosu)

**Backend:**
- Supabase (Auth, Database, Storage, Edge Functions)
- Deno/TypeScript (Edge Functions)
- PostgreSQL (Database)
- OpenAI/Anthropic (LLM)
- Firebase Cloud Messaging (Push Notifications)

### Proje Yapısı

```
Fal-Astro/
├── flutter_app/
│   └── lib/
│       ├── core/
│       │   └── services/
│       │       ├── ad_service.dart              # Google Ads servisi
│       │       ├── push_notification_service.dart # FCM servisi
│       │       └── social_auth_service.dart     # Google/Apple OAuth
│       ├── data/
│       │   ├── models/
│       │   │   └── user_profile.dart       # V2 gamification alanları
│       │   └── services/
│       ├── presentation/
│       │   ├── providers/
│       │   │   ├── auth_provider.dart
│       │   │   ├── profile_provider.dart
│       │   │   └── ad_provider.dart        # Reklam provider
│       │   ├── router/
│       │   │   ├── app_router.dart         # 5 tab navigasyon
│       │   │   └── route_names.dart
│       │   ├── screens/
│       │   │   ├── home/
│       │   │   ├── fortune/
│       │   │   ├── dreams/                 # Rüya yorumu (sesli giriş)
│       │   │   ├── astro/
│       │   │   ├── synastry/               # Burç uyumu
│       │   │   ├── shop/                   # Kredi mağazası
│       │   │   ├── achievements/           # Başarımlar
│       │   │   ├── admin/                  # Admin paneli (bildirim gönderimi)
│       │   │   ├── auth/                   # Giriş ekranı (Google/Apple)
│       │   │   │   └── widgets/
│       │   │   │       ├── google_sign_in_button.dart
│       │   │   │       └── apple_sign_in_button.dart
│       │   │   └── profile/
│       │   └── widgets/
│       │       ├── loading/
│       │       │   └── mystic_loading_overlay.dart
│       │       ├── share/
│       │       │   └── story_share_card.dart
│       │       ├── gamification/
│       │       │   └── user_stats_card.dart
│       │       └── legal/
│       │           └── legal_consent_dialog.dart
│       └── env/
│
├── supabase/
│   ├── migrations/
│   │   ├── 20240101000000_initial_schema.sql
│   │   ├── 20240202000000_upgrade_v2_ultimate.sql
│   │   ├── 20240202100000_add_credits_rpc.sql
│   │   └── 20240202200000_notification_logs.sql
│   └── functions/
│       ├── _shared/
│       ├── fortune_read/
│       ├── dream-interpret/
│       ├── cron-daily-generator/
│       ├── daily_astro/
│       ├── astro_report/
│       └── send-notification/              # FCM bildirim gönderimi
│
├── .github/
│   └── workflows/
│       └── deploy-functions.yml    # Edge Functions CI/CD
│
└── README.md
```

---

## Kurulum

### 1. Flutter Kurulumu

```bash
cd flutter_app
flutter pub get
```

### 2. Supabase Kurulumu

```bash
# Supabase CLI
npm install -g supabase
supabase login
supabase link --project-ref your-project-ref

# Migrations
supabase db push
```

### 3. Environment Variables

Flutter için `--dart-define` kullanın:
```bash
flutter run \
  --dart-define=SUPABASE_URL=https://xxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=xxx
```

Edge Functions için Supabase Secrets:
```bash
supabase secrets set OPENAI_API_KEY=sk-xxx
supabase secrets set LLM_PROVIDER=openai
supabase secrets set FIREBASE_SERVER_KEY=your-firebase-server-key
```

### 4. Google Ads Kurulumu

1. AdMob hesabı oluşturun
2. App ID'leri alın
3. `ad_service.dart` dosyasında production ID'leri güncelleyin
4. Android: `AndroidManifest.xml`'e AdMob App ID ekleyin
5. iOS: `Info.plist`'e GADApplicationIdentifier ekleyin

### 5. Firebase Kurulumu (Push Notifications)

1. [Firebase Console](https://console.firebase.google.com/)'da proje oluşturun
2. Android uygulaması ekleyin:
   - Package name: `com.example.fal_astro`
   - `google-services.json` dosyasını `android/app/` klasörüne kopyalayın
3. iOS uygulaması ekleyin:
   - Bundle ID: `com.example.falAstro`
   - `GoogleService-Info.plist` dosyasını Xcode'da Runner'a ekleyin
4. Cloud Messaging'i etkinleştirin
5. Server Key'i Supabase Edge Function secrets'a ekleyin:
   ```bash
   supabase secrets set FIREBASE_SERVER_KEY=your-server-key
   ```

### 6. Google Sign In Kurulumu

1. [Google Cloud Console](https://console.cloud.google.com/)'da proje oluşturun
2. OAuth 2.0 Client ID'leri oluşturun:
   - **Web Client**: Supabase OAuth için
   - **iOS Client**: iOS uygulaması için
   - **Android Client**: SHA-1 fingerprint ile
3. `social_auth_service.dart` dosyasında Client ID'leri güncelleyin:
   ```dart
   static const String _webClientId = 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';
   static const String _iosClientId = 'YOUR_IOS_CLIENT_ID.apps.googleusercontent.com';
   ```
4. Supabase Dashboard'da Google Provider'ı etkinleştirin:
   - Authentication > Providers > Google
   - Web Client ID ve Secret'ı ekleyin

### 7. Apple Sign In Kurulumu (iOS)

1. [Apple Developer Portal](https://developer.apple.com/)'da:
   - App ID oluşturun (Sign In with Apple capability)
   - Services ID oluşturun (Supabase callback URL ile)
   - Key oluşturun (Sign In with Apple)
2. Xcode'da:
   - Signing & Capabilities > Sign In with Apple ekleyin
3. Supabase Dashboard'da Apple Provider'ı etkinleştirin:
   - Authentication > Providers > Apple
   - Service ID, Team ID, Key ID ve Private Key ekleyin

### 8. Info.plist Gereksinimleri (iOS)

```xml
<!-- Google Sign In -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR_IOS_CLIENT_ID</string>
        </array>
    </dict>
</array>

<!-- Firebase -->
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>

<!-- Push Notifications -->
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

### 9. AndroidManifest.xml Gereksinimleri

```xml
<!-- Internet permission (zaten var) -->
<uses-permission android:name="android.permission.INTERNET"/>

<!-- Google Ads -->
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-YOUR_APP_ID"/>
```

---

## Veritabanı Şeması

### Ana Tablolar

- `profiles` - Kullanıcı profilleri (V2: credits, streak, level, xp, fcm_token, is_admin)
- `fortune_readings` - Kahve falı kayıtları
- `dream_interpretations` - Rüya yorumları
- `daily_horoscopes` - Günlük burç yorumları
- `credit_packages` - Satın alınabilir kredi paketleri
- `credit_transactions` - Kredi işlem geçmişi
- `achievements` - Başarım tanımları
- `user_achievements` - Kullanıcı başarımları
- `consent_audit_log` - GDPR/KVKK onay kayıtları
- `notification_logs` - Gönderilen bildirim kayıtları

### RPC Fonksiyonları

- `add_user_credits(amount, type, desc)` - Kredi ekleme
- `check_daily_ad_limit()` - Günlük reklam limiti kontrolü
- `update_fcm_token(token)` - FCM token güncelleme

---

## API Endpoints

### Edge Functions

| Endpoint | Method | Açıklama |
|----------|--------|----------|
| `/fortune_read` | POST | Kahve falı okuma |
| `/dream-interpret` | POST | Rüya yorumlama |
| `/daily_astro` | POST | Günlük astroloji |
| `/astro_report` | POST | Astroloji raporu |
| `/cron-daily-generator` | POST | Günlük burç üretimi |
| `/synastry-calculate` | POST | Burç uyumu hesaplama |
| `/send-notification` | POST | FCM push bildirim gönderimi |

---

## Güvenlik

- **RLS (Row Level Security)**: Tüm tablolarda etkin
- **Storage Security**: Path tabanlı erişim (`{user_id}/{reading_id}/`)
- **API Keys**: Sadece Edge Functions'da (client'ta yok)
- **Rate Limiting**: Tier bazlı günlük limitler
- **Input Sanitization**: Prompt injection önleme

---

## Rate Limits

| Tier | Fal/Gün | Rüya/Gün | Reklam/Gün |
|------|---------|----------|------------|
| Free | 1 | 1 | 5 |
| Premium | 10 | 10 | 10 |

---

## Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Commit yapın (`git commit -m 'Add amazing feature'`)
4. Push yapın (`git push origin feature/amazing-feature`)
5. Pull Request açın

---

## Lisans

Bu proje özel lisans altındadır. Ticari kullanım için izin gereklidir.

---

## İletişim

Sorular ve öneriler için: [GitHub Issues](https://github.com/yalpyy/Fal-Astro/issues)
