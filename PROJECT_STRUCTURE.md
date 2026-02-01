# Fal & Astro - Proje Dosya Yapısı

```
fal_astro/
├── supabase/
│   ├── migrations/
│   │   └── 20240101000000_initial_schema.sql    # Tablolar, indexler, triggers
│   ├── functions/
│   │   ├── _shared/
│   │   │   ├── llm_provider.ts                  # LLM abstraction layer
│   │   │   ├── rate_limiter.ts                  # Rate limiting logic
│   │   │   ├── sanitizer.ts                     # Input sanitization
│   │   │   ├── schema_validator.ts              # JSON schema validation
│   │   │   └── cors.ts                          # CORS headers
│   │   ├── fortune_read/
│   │   │   └── index.ts                         # Kahve falı okuma
│   │   ├── daily_astro/
│   │   │   └── index.ts                         # Günlük astroloji
│   │   ├── astro_report/
│   │   │   └── index.ts                         # Natal/haftalık/aylık rapor
│   │   └── compat_report/
│   │       └── index.ts                         # Uyum raporu (opsiyon)
│   ├── seed.sql                                 # Test verileri (dev)
│   └── config.toml                              # Supabase local config
│
├── flutter_app/
│   ├── lib/
│   │   ├── main.dart                            # Entry point
│   │   ├── app.dart                             # MaterialApp config
│   │   │
│   │   ├── core/
│   │   │   ├── constants/
│   │   │   │   ├── app_constants.dart           # Sabitler
│   │   │   │   └── supabase_constants.dart      # Bucket/function names
│   │   │   ├── errors/
│   │   │   │   ├── failures.dart                # Failure sınıfları
│   │   │   │   └── exceptions.dart              # Exception sınıfları
│   │   │   ├── extensions/
│   │   │   │   ├── context_extensions.dart      # BuildContext extensions
│   │   │   │   └── date_extensions.dart         # DateTime extensions
│   │   │   ├── theme/
│   │   │   │   ├── app_theme.dart               # ThemeData (light/dark)
│   │   │   │   └── app_colors.dart              # Renk paleti
│   │   │   ├── utils/
│   │   │   │   ├── validators.dart              # Form validators
│   │   │   │   └── formatters.dart              # Date/text formatters
│   │   │   └── l10n/
│   │   │       ├── app_localizations.dart       # Localization delegate
│   │   │       ├── intl_en.arb                  # English strings
│   │   │       └── intl_tr.arb                  # Turkish strings
│   │   │
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── user_profile.dart            # Profile model
│   │   │   │   ├── birth_profile.dart           # Doğum bilgileri
│   │   │   │   ├── fortune_reading.dart         # Fal sonucu
│   │   │   │   ├── fortune_feedback.dart        # Feedback
│   │   │   │   ├── astro_report.dart            # Astro rapor
│   │   │   │   ├── daily_astro.dart             # Günlük astro
│   │   │   │   ├── subscription.dart            # Abonelik
│   │   │   │   └── symbol.dart                  # Fal sembolleri
│   │   │   ├── repositories/
│   │   │   │   ├── auth_repository.dart         # Auth işlemleri
│   │   │   │   ├── profile_repository.dart      # Profil CRUD
│   │   │   │   ├── fortune_repository.dart      # Fal CRUD
│   │   │   │   ├── astro_repository.dart        # Astro CRUD
│   │   │   │   └── subscription_repository.dart # Abonelik
│   │   │   └── services/
│   │   │       ├── storage_service.dart         # Supabase Storage
│   │   │       ├── functions_service.dart       # Edge Functions
│   │   │       ├── local_cache_service.dart     # SharedPreferences/Hive
│   │   │       └── notification_service.dart    # Local notifications
│   │   │
│   │   ├── presentation/
│   │   │   ├── router/
│   │   │   │   ├── app_router.dart              # GoRouter config
│   │   │   │   └── route_names.dart             # Route constants
│   │   │   ├── providers/
│   │   │   │   ├── auth_provider.dart           # Auth state
│   │   │   │   ├── profile_provider.dart        # Profile state
│   │   │   │   ├── fortune_provider.dart        # Fortune state
│   │   │   │   ├── astro_provider.dart          # Astro state
│   │   │   │   ├── theme_provider.dart          # Theme state
│   │   │   │   ├── locale_provider.dart         # Locale state
│   │   │   │   └── subscription_provider.dart   # Premium state
│   │   │   ├── screens/
│   │   │   │   ├── splash/
│   │   │   │   │   └── splash_screen.dart
│   │   │   │   ├── auth/
│   │   │   │   │   ├── auth_screen.dart
│   │   │   │   │   └── widgets/
│   │   │   │   │       ├── apple_sign_in_button.dart
│   │   │   │   │       └── email_sign_in_form.dart
│   │   │   │   ├── onboarding/
│   │   │   │   │   ├── onboarding_screen.dart
│   │   │   │   │   └── widgets/
│   │   │   │   │       └── birth_info_form.dart
│   │   │   │   ├── home/
│   │   │   │   │   ├── home_screen.dart
│   │   │   │   │   └── widgets/
│   │   │   │   │       ├── fortune_card.dart
│   │   │   │   │       └── astro_card.dart
│   │   │   │   ├── fortune/
│   │   │   │   │   ├── fortune_upload_screen.dart
│   │   │   │   │   ├── fortune_result_screen.dart
│   │   │   │   │   └── widgets/
│   │   │   │   │       ├── image_picker_card.dart
│   │   │   │   │       ├── intent_selector.dart
│   │   │   │   │       ├── symbol_card.dart
│   │   │   │   │       └── timeline_widget.dart
│   │   │   │   ├── astro/
│   │   │   │   │   ├── astro_report_screen.dart
│   │   │   │   │   └── widgets/
│   │   │   │   │       ├── report_tab.dart
│   │   │   │   │       └── daily_astro_card.dart
│   │   │   │   ├── history/
│   │   │   │   │   ├── history_screen.dart
│   │   │   │   │   └── widgets/
│   │   │   │   │       ├── fortune_history_item.dart
│   │   │   │   │       └── astro_history_item.dart
│   │   │   │   ├── profile/
│   │   │   │   │   ├── profile_screen.dart
│   │   │   │   │   └── widgets/
│   │   │   │   │       └── settings_tile.dart
│   │   │   │   └── feedback/
│   │   │   │       └── feedback_dialog.dart
│   │   │   └── widgets/
│   │   │       ├── common/
│   │   │       │   ├── loading_overlay.dart
│   │   │       │   ├── error_widget.dart
│   │   │       │   ├── empty_state.dart
│   │   │       │   ├── skeleton_loader.dart
│   │   │       │   └── disclaimer_banner.dart
│   │   │       └── dialogs/
│   │   │           ├── confirmation_dialog.dart
│   │   │           └── premium_upsell_dialog.dart
│   │   │
│   │   └── env/
│   │       └── env.dart                         # Environment variables
│   │
│   ├── test/
│   │   ├── repositories/
│   │   │   ├── auth_repository_test.dart
│   │   │   └── fortune_repository_test.dart
│   │   └── providers/
│   │       └── auth_provider_test.dart
│   │
│   ├── assets/
│   │   ├── images/
│   │   │   ├── logo.png
│   │   │   └── placeholder_cup.png
│   │   └── fonts/
│   │
│   ├── pubspec.yaml
│   ├── analysis_options.yaml
│   └── .env.example
│
├── docs/
│   ├── prompt_templates.md                      # LLM prompt şablonları
│   ├── db_schema.md                             # DB şeması diyagramı
│   └── mvp_checklist.md                         # MVP kontrol listesi
│
├── .gitignore
├── README.md
└── LICENSE
```

## Dizin Açıklamaları

### `/supabase`
Supabase projesinin tüm backend bileşenlerini içerir:
- **migrations/**: SQL migration dosyaları (tablo, index, trigger, RLS)
- **functions/**: Deno/TypeScript Edge Functions
- **_shared/**: Functions arası paylaşılan utility kodlar

### `/flutter_app`
Flutter mobil uygulaması (Clean Architecture prensiplerine uygun):

#### `/lib/core`
Uygulamanın temel yapı taşları:
- **constants/**: Sabit değerler
- **errors/**: Hata yönetimi sınıfları
- **extensions/**: Dart extension methods
- **theme/**: Material 3 tema tanımları
- **utils/**: Yardımcı fonksiyonlar
- **l10n/**: Çoklu dil desteği (TR/EN)

#### `/lib/data`
Veri katmanı:
- **models/**: Domain modelleri (freezed veya manual)
- **repositories/**: Supabase ile iletişim
- **services/**: Storage, Functions, Cache servisleri

#### `/lib/presentation`
Sunum katmanı:
- **router/**: go_router yapılandırması
- **providers/**: Riverpod state management
- **screens/**: Ekranlar ve widget'ları
- **widgets/**: Paylaşılan UI bileşenleri

### `/docs`
Proje dokümantasyonu:
- Prompt şablonları
- DB şeması
- MVP kontrol listesi
