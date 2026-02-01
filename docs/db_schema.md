# Database Schema

## Entity Relationship Diagram (Text)

```
┌──────────────────┐
│   auth.users     │
│──────────────────│
│ id (uuid) PK     │
│ email            │
│ ...              │
└────────┬─────────┘
         │
         │ 1:1
         ▼
┌──────────────────┐      ┌──────────────────┐
│     profiles     │      │  birth_profiles  │
│──────────────────│      │──────────────────│
│ id (uuid) PK/FK  │      │ user_id (uuid)   │
│ name             │      │   PK/FK          │
│ avatar_url       │      │ birth_date       │
│ locale           │      │ birth_time       │
│ created_at       │      │ birth_city       │
│ updated_at       │      │ birth_country    │
└──────────────────┘      │ timezone         │
                          │ unknown_time     │
                          └──────────────────┘

┌──────────────────┐      ┌──────────────────┐
│ fortune_readings │      │ fortune_feedback │
│──────────────────│      │──────────────────│
│ id (uuid) PK     │◄────▶│ id (uuid) PK     │
│ user_id FK       │      │ reading_id FK    │
│ intent           │      │ user_id FK       │
│ cup_image_path   │      │ is_accurate      │
│ saucer_image_path│      │ accuracy_rating  │
│ result_text      │      │ note             │
│ symbols (jsonb)  │      │ feedback_date    │
│ timelines (jsonb)│      │ created_at       │
│ status           │      └──────────────────┘
│ created_at       │
│ updated_at       │
└──────────────────┘

┌──────────────────┐      ┌──────────────────┐
│   astro_reports  │      │daily_astro_cache │
│──────────────────│      │──────────────────│
│ id (uuid) PK     │      │ user_id PK/FK    │
│ user_id FK       │      │ date PK          │
│ report_type      │      │ zodiac_sign      │
│ chart_json       │      │ content          │
│ report_text      │      │ mood_score       │
│ sections (jsonb) │      │ lucky_numbers    │
│ status           │      │ lucky_color      │
│ valid_until      │      │ created_at       │
│ created_at       │      └──────────────────┘
│ updated_at       │
└──────────────────┘

┌──────────────────┐      ┌──────────────────┐
│  subscriptions   │      │   usage_limits   │
│──────────────────│      │──────────────────│
│ user_id PK/FK    │      │ user_id PK/FK    │
│ provider         │      │ date PK          │
│ product_id       │      │ fortune_count    │
│ status           │      │ astro_report_cnt │
│ tier             │      │ daily_astro_cnt  │
│ starts_at        │      │ created_at       │
│ expires_at       │      │ updated_at       │
│ trial_ends_at    │      └──────────────────┘
│ receipt_data     │
│ updated_at       │
└──────────────────┘

┌──────────────────┐
│feedback_reminders│
│──────────────────│
│ id (uuid) PK     │
│ user_id FK       │
│ reading_id FK    │
│ remind_at        │
│ reminded         │
│ created_at       │
└──────────────────┘
```

## Tables Detail

### profiles
Kullanıcı profil bilgileri (auth.users'ı extend eder)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK, FK(auth.users.id) | Kullanıcı ID |
| name | text | - | Ad soyad |
| avatar_url | text | - | Profil fotoğrafı URL |
| locale | text | DEFAULT 'tr' | Tercih edilen dil |
| created_at | timestamptz | NOT NULL | Oluşturma tarihi |
| updated_at | timestamptz | NOT NULL | Güncelleme tarihi |

### birth_profiles
Astroloji hesaplamaları için doğum bilgileri

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| user_id | uuid | PK, FK | Kullanıcı ID |
| birth_date | date | NOT NULL | Doğum tarihi |
| birth_time | time | - | Doğum saati (opsiyonel) |
| birth_city | text | NOT NULL | Doğum şehri |
| birth_country | text | NOT NULL | Doğum ülkesi |
| timezone | text | DEFAULT 'Europe/Istanbul' | Timezone |
| unknown_time | boolean | DEFAULT FALSE | Saat bilinmiyor mu |
| latitude | decimal(10,8) | - | Enlem |
| longitude | decimal(11,8) | - | Boylam |

### fortune_readings
Kahve falı kayıtları

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | Fal ID |
| user_id | uuid | FK, NOT NULL | Kullanıcı ID |
| intent | text | CHECK IN (...) | Niyet türü |
| cup_image_path | text | NOT NULL | Fincan fotoğrafı path |
| saucer_image_path | text | - | Tabak fotoğrafı path |
| result_text | text | - | Yorum metni |
| symbols | jsonb | DEFAULT '[]' | Semboller listesi |
| timelines | jsonb | DEFAULT '{}' | Zaman tahminleri |
| status | text | CHECK IN (...) | Durum |
| error_message | text | - | Hata mesajı |
| processing_time_ms | integer | - | İşlem süresi |

### fortune_feedback
"Tuttu mu?" geri bildirimleri

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | uuid | PK | Feedback ID |
| reading_id | uuid | FK, UNIQUE | Fal ID |
| user_id | uuid | FK | Kullanıcı ID |
| is_accurate | boolean | NOT NULL | Tuttu mu? |
| accuracy_rating | integer | CHECK 1-5 | Doğruluk puanı |
| note | text | - | Kullanıcı notu |
| feedback_date | timestamptz | NOT NULL | Feedback tarihi |

### subscriptions
Abonelik bilgileri

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| user_id | uuid | PK, FK | Kullanıcı ID |
| provider | text | CHECK IN (...) | apple/google/manual |
| product_id | text | - | Store ürün ID |
| status | text | CHECK IN (...) | Abonelik durumu |
| tier | text | CHECK IN (...) | free/premium/premium_plus |
| starts_at | timestamptz | - | Başlangıç tarihi |
| expires_at | timestamptz | - | Bitiş tarihi |
| trial_ends_at | timestamptz | - | Deneme bitiş tarihi |
| receipt_data | text | - | Store receipt (encrypted) |

## Indexes

```sql
-- Fortune readings
CREATE INDEX idx_fortune_readings_user_id ON fortune_readings(user_id);
CREATE INDEX idx_fortune_readings_created_at ON fortune_readings(created_at DESC);
CREATE INDEX idx_fortune_readings_status ON fortune_readings(status) WHERE status = 'pending';

-- Astro reports
CREATE INDEX idx_astro_reports_user_type ON astro_reports(user_id, report_type);

-- Subscriptions
CREATE INDEX idx_subscriptions_status ON subscriptions(status) WHERE status = 'active';
```

## RLS Policies Summary

Tüm tablolarda "kullanıcı sadece kendi verisini görebilir" prensibi uygulanır:

```sql
-- SELECT: auth.uid() = user_id (veya id)
-- INSERT: user_id = auth.uid()
-- UPDATE: auth.uid() = user_id
-- DELETE: auth.uid() = user_id
```

Storage RLS (fortune-images bucket):
- Path formatı: `{user_id}/{reading_id}/{filename}`
- Tüm işlemler için path'in ilk segmenti auth.uid() ile eşleşmeli
