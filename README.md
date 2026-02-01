# Fal & Astro

Kahve falı ve kişiye özel astroloji uygulaması.

## Özellikler

### Kahve Falı
- Fincan (ve opsiyonel tabak) fotoğrafı yükleme
- Niyet seçimi: Aşk, Para, Kariyer, Genel
- AI tabanlı detaylı yorum
- 3 zaman çizelgesi: 7 gün, 1 ay, 3 ay
- Sembol tanıma ve açıklama
- "Tuttu mu?" geri bildirim sistemi

### Astroloji
- Kişisel doğum haritası profili
- Günlük astroloji yorumu
- Natal/haftalık/aylık/yıllık raporlar
- Aşk ve kariyer raporları
- İlişki uyum analizi (opsiyonel)

### Teknik
- Flutter (iOS/Android)
- Supabase Backend (Auth, Database, Storage, Edge Functions)
- LLM entegrasyonu (OpenAI/Anthropic)
- Riverpod state management
- Material 3 UI
- Türkçe/İngilizce dil desteği

---

## Kurulum

### Gereksinimler

- Flutter SDK 3.2+
- Dart SDK 3.2+
- Supabase CLI
- Node.js 18+ (Edge Functions için)

### 1. Supabase Projesi Oluşturma

```bash
# Supabase CLI kurulumu
npm install -g supabase

# Giriş
supabase login

# Yeni proje oluştur (Supabase Dashboard'dan)
# veya mevcut projeye bağlan
supabase link --project-ref your-project-ref
```

### 2. Veritabanı Kurulumu

```bash
cd supabase

# Migration çalıştır
supabase db push

# Veya SQL dosyasını manuel çalıştır
# migrations/20240101000000_initial_schema.sql
```

### 3. Storage Bucket Oluşturma

Supabase Dashboard > Storage > New bucket:
- Name: `fortune-images`
- Public: `false`
- File size limit: `5MB`
- Allowed MIME types: `image/jpeg, image/png, image/webp`

### 4. Edge Functions Deploy

```bash
# Tüm fonksiyonları deploy et
supabase functions deploy fortune_read
supabase functions deploy daily_astro
supabase functions deploy astro_report
supabase functions deploy compat_report

# Secrets ayarla
supabase secrets set LLM_PROVIDER=openai
supabase secrets set OPENAI_API_KEY=sk-xxx
# veya
supabase secrets set LLM_PROVIDER=anthropic
supabase secrets set ANTHROPIC_API_KEY=sk-xxx
```

### 5. Flutter Uygulaması

```bash
cd flutter_app

# Bağımlılıkları yükle
flutter pub get

# Kod üretimi (freezed/json_serializable kullanıyorsanız)
flutter pub run build_runner build --delete-conflicting-outputs

# Çalıştır
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

### 6. Apple Sign In Kurulumu (iOS)

1. Apple Developer Portal'da Sign In with Apple capability ekle
2. Supabase Dashboard > Authentication > Providers > Apple'ı etkinleştir
3. Bundle ID ve Secret Key'i Supabase'e ekle

---

## Proje Yapısı

```
fal_astro/
├── supabase/
│   ├── migrations/          # SQL migrations
│   ├── functions/           # Edge Functions
│   │   ├── _shared/         # Paylaşılan utilities
│   │   ├── fortune_read/    # Kahve falı
│   │   ├── daily_astro/     # Günlük astro
│   │   ├── astro_report/    # Astro raporları
│   │   └── compat_report/   # Uyum raporu
│   └── config.toml          # Local config
│
├── flutter_app/
│   ├── lib/
│   │   ├── core/            # Constants, theme, utils
│   │   ├── data/            # Models, repositories, services
│   │   ├── presentation/    # Providers, screens, widgets
│   │   └── env/             # Environment config
│   └── test/                # Unit tests
│
├── docs/
│   ├── prompt_templates.md  # LLM prompt şablonları
│   ├── db_schema.md         # DB şeması diyagramı
│   └── mvp_checklist.md     # MVP kontrol listesi
│
└── README.md
```

---

## Environment Variables

### Flutter (.env.example)

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
APPLE_CLIENT_ID=your.bundle.id
APPLE_REDIRECT_URI=https://your-project.supabase.co/auth/v1/callback
```

### Edge Functions (Supabase Secrets)

```bash
# LLM Provider
LLM_PROVIDER=openai  # veya anthropic
OPENAI_API_KEY=sk-xxx
ANTHROPIC_API_KEY=sk-xxx
LLM_MODEL=gpt-4o  # veya claude-sonnet-4-20250514
LLM_MAX_TOKENS=2048
LLM_TEMPERATURE=0.7
```

---

## API Endpoints

### Edge Functions

#### POST /fortune_read
Kahve falı okuma

Request:
```json
{
  "intent": "love|money|career|general",
  "cup_image_signed_url": "...",
  "saucer_image_signed_url": "...",
  "locale": "tr|en",
  "custom_note": "..."
}
```

Response:
```json
{
  "reading_id": "uuid",
  "result_text": "...",
  "timelines": {"near": "...", "mid": "...", "far": "..."},
  "symbols": [{"name": "...", "meaning": "...", "confidence": 0.85}],
  "safety_note": "...",
  "remaining_today": 0
}
```

#### POST /daily_astro
Günlük astroloji

#### POST /astro_report
Astroloji raporu

#### POST /compat_report
Uyum raporu

---

## Güvenlik

### RLS (Row Level Security)
Tüm tablolarda etkin. Kullanıcılar sadece kendi verilerine erişebilir.

### Storage Security
Fortune-images bucket'ta path tabanlı RLS. Format: `{user_id}/{reading_id}/{filename}`

### LLM Security
- Input sanitization (prompt injection önleme)
- Output validation (tehlikeli içerik filtreleme)
- Rate limiting (tier bazlı günlük limit)
- API key'ler sadece Edge Functions'da (client'ta yok)

---

## Rate Limits

| Tier | Fal/Gün | Astro Rapor/Gün | Günlük Astro/Gün |
|------|---------|-----------------|------------------|
| Free | 1 | 1 | 3 |
| Premium | 10 | 5 | 10 |
| Premium+ | Sınırsız | Sınırsız | Sınırsız |

---

## Lisans

Bu proje özel lisans altındadır. Ticari kullanım için izin gereklidir.

---

## Destek

Sorular ve öneriler için: [GitHub Issues](https://github.com/your-repo/issues)
