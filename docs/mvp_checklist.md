# MVP Checklist

## Backend (Supabase)

### Database
- [x] profiles tablosu
- [x] birth_profiles tablosu
- [x] fortune_readings tablosu
- [x] fortune_feedback tablosu
- [x] astro_reports tablosu
- [x] daily_astro_cache tablosu
- [x] subscriptions tablosu
- [x] usage_limits tablosu
- [x] feedback_reminders tablosu
- [x] Indexes
- [x] Triggers (updated_at, new user, feedback reminder)

### RLS Policies
- [x] profiles RLS
- [x] birth_profiles RLS
- [x] fortune_readings RLS
- [x] fortune_feedback RLS
- [x] astro_reports RLS
- [x] daily_astro_cache RLS
- [x] subscriptions RLS (sadece okuma)
- [x] usage_limits RLS (sadece okuma)
- [x] Storage (fortune-images) RLS

### Edge Functions
- [x] fortune_read - kahve falı okuma
- [x] daily_astro - günlük astroloji
- [x] astro_report - astroloji raporları
- [x] compat_report - uyum raporu (opsiyonel)
- [x] LLM provider abstraction
- [x] Rate limiting
- [x] Input sanitization
- [x] Output validation

### Storage
- [ ] fortune-images bucket oluşturma
- [ ] Bucket RLS policies uygulama

---

## Flutter App

### Core
- [x] Environment config
- [x] Theme (light/dark)
- [x] Localization (TR/EN)
- [x] Constants
- [x] Error handling

### Data Layer
- [x] Models (all)
- [x] AuthRepository
- [x] ProfileRepository
- [x] FortuneRepository
- [x] AstroRepository
- [x] SubscriptionRepository
- [x] StorageService
- [x] FunctionsService
- [x] LocalCacheService
- [x] NotificationService

### State Management (Riverpod)
- [x] AuthProvider
- [x] ProfileProvider
- [x] FortuneProvider
- [x] AstroProvider
- [x] ThemeProvider
- [x] LocaleProvider
- [x] SubscriptionProvider

### Screens
- [x] SplashScreen
- [x] AuthScreen
- [x] OnboardingScreen (doğum bilgileri)
- [x] HomeScreen
- [x] FortuneUploadScreen
- [x] FortuneResultScreen
- [x] AstroReportScreen
- [x] HistoryScreen
- [x] ProfileScreen
- [ ] FeedbackDialog
- [ ] PremiumScreen

### Navigation
- [x] GoRouter setup
- [x] Auth redirect logic
- [x] Bottom navigation
- [x] Deep linking structure

### UI/UX
- [x] Loading overlay
- [x] Disclaimer banner
- [ ] Error widget
- [ ] Empty state widget
- [ ] Skeleton loader
- [ ] Premium upsell dialog

---

## Pre-Launch Tasks

### Supabase Setup
- [ ] Project oluştur
- [ ] Migration çalıştır
- [ ] Storage bucket oluştur
- [ ] Edge functions deploy et
- [ ] Environment variables ayarla (LLM keys)

### Apple Setup
- [ ] App Store Connect'te uygulama oluştur
- [ ] Apple Sign In capability ekle
- [ ] Bundle ID kaydet
- [ ] Supabase'de Apple provider ayarla

### Flutter Setup
- [ ] Bundle ID ayarla (iOS/Android)
- [ ] Icons ve splash screen
- [ ] firebase_options.dart (push notifications için - opsiyonel)

### Testing
- [ ] Auth flow test
- [ ] Fortune reading flow test
- [ ] Astro report flow test
- [ ] Subscription flow test (sandbox)

### Compliance
- [ ] Privacy Policy
- [ ] Terms of Service
- [ ] App Store guidelines review
- [ ] KVKK/GDPR uyumu

---

## Post-MVP Improvements

### Features
- [ ] Push notifications (günlük hatırlatma)
- [ ] Share functionality (fal sonucu paylaşma)
- [ ] Widget (home screen widget)
- [ ] Apple Watch companion (opsiyonel)

### Performance
- [ ] Image compression/optimization
- [ ] Offline-first caching
- [ ] Background sync

### Analytics
- [ ] Event tracking
- [ ] User retention metrics
- [ ] Feature usage tracking

### Monetization
- [ ] In-app purchase full implementation
- [ ] Receipt validation
- [ ] Subscription management
