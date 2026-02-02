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

### Admin & Yönetim

| Özellik | Durum | Açıklama |
|---------|-------|----------|
| Admin Panel | ✅ Tamamlandı | İstatistikler, kullanıcı yönetimi |
| Günlük Burç Tetikleme | ✅ Tamamlandı | Manuel cron tetikleme |
| Kullanıcı İstatistikleri | ✅ Tamamlandı | Toplam kullanıcı, aktif, fal sayısı |

---

## Yapılacaklar (TODO)

### Yüksek Öncelik
- [ ] **In-App Purchase Entegrasyonu** - Gerçek ödeme sistemi
- [ ] **Push Notifications** - Firebase/OneSignal entegrasyonu
- [ ] **Apple Sign In** - iOS için zorunlu
- [ ] **Google Sign In** - Android için
- [ ] **Production Ad Unit IDs** - Gerçek reklam ID'leri

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

**Backend:**
- Supabase (Auth, Database, Storage, Edge Functions)
- Deno/TypeScript (Edge Functions)
- PostgreSQL (Database)
- OpenAI/Anthropic (LLM)

### Proje Yapısı

```
Fal-Astro/
├── flutter_app/
│   └── lib/
│       ├── core/
│       │   └── services/
│       │       └── ad_service.dart         # Google Ads servisi
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
│       │   │   ├── dreams/                 # Rüya yorumu
│       │   │   ├── astro/
│       │   │   ├── synastry/              # Burç uyumu
│       │   │   ├── shop/                   # Kredi mağazası
│       │   │   ├── achievements/           # Başarımlar
│       │   │   ├── admin/                  # Admin paneli
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
│   │   └── 20240202100000_add_credits_rpc.sql
│   └── functions/
│       ├── _shared/
│       ├── fortune_read/
│       ├── dream-interpret/
│       ├── cron-daily-generator/
│       ├── daily_astro/
│       └── astro_report/
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
```

### 4. Google Ads Kurulumu

1. AdMob hesabı oluşturun
2. App ID'leri alın
3. `ad_service.dart` dosyasında production ID'leri güncelleyin
4. Android: `AndroidManifest.xml`'e AdMob App ID ekleyin
5. iOS: `Info.plist`'e GADApplicationIdentifier ekleyin

---

## Veritabanı Şeması

### Ana Tablolar

- `profiles` - Kullanıcı profilleri (V2: credits, streak, level, xp)
- `fortune_readings` - Kahve falı kayıtları
- `dream_interpretations` - Rüya yorumları
- `daily_horoscopes` - Günlük burç yorumları
- `credit_packages` - Satın alınabilir kredi paketleri
- `credit_transactions` - Kredi işlem geçmişi
- `achievements` - Başarım tanımları
- `user_achievements` - Kullanıcı başarımları
- `consent_audit_log` - GDPR/KVKK onay kayıtları

### RPC Fonksiyonları

- `add_user_credits(amount, type, desc)` - Kredi ekleme
- `check_daily_ad_limit()` - Günlük reklam limiti kontrolü

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
