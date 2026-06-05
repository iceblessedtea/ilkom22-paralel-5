# Folder Structure

Struktur folder sudah dirapikan agar fungsi setiap bagian lebih jelas.

```text
.
  docs/
  frontend/
  legacy/
  observability/
  services/
```

## docs

Berisi dokumentasi project: overview, folder structure, tech stack, arsitektur, environment, running guide, API reference, observability, roadmap, dan catatan keputusan teknis.

## frontend

Berisi aplikasi frontend React + TypeScript + Vite.

```text
frontend/
  src/
    components/
    pages/
    services/        # pemanggilan API ke backend
    App.tsx
    main.tsx
  index.html
  package.json
  vite.config.ts
  .env.example       # contoh konfigurasi VITE_API_BASE_URL
```

Nama sebelumnya: `fe_react` → nama baru: `frontend`.

## services

Berisi backend services aktif.

```text
services/
  api-gateway/
  appointment-service/
  doctor-service/
  medical-record-service/
  patient-service/
  scripts/
  docker-compose.yml
```

Struktur umum tiap service:

```text
<service>/
  app.rb            # definisi route Sinatra
  config.ru         # entry point Rack
  Gemfile
  db/               # migrasi & file SQLite
  lib/              # helper, klien HTTP antar-service
  spec/             # RSpec (unit & request spec)
  .env.example      # contoh environment variable service
```

Nama sebelumnya: `microservice` → nama baru: `services`.

## observability

Berisi konfigurasi OpenTelemetry: collector config, compose tambahan, dan konfigurasi Ruby shared.

```text
observability/
  docker-compose.otel.yml
  otel-collector-config.yaml
  ruby/
    otel.rb
```

## legacy

Berisi kode lama, prototype, atau eksperimen yang tidak dijadikan struktur utama saat ini.

Mapping nama lama ke nama baru:

```text
doctors_service      -> legacy/doctors-service
pasien_service       -> legacy/patients-web-service
rekammedik_service   -> legacy/medical-records-web-service
janjitemu_service    -> legacy/appointments-web-service
janjitemu_backend    -> legacy/appointments-backend-service
janjitemu            -> legacy/appointments-prototype
pasien               -> legacy/patients-prototype
```

Tujuan folder `legacy` adalah menjaga kode lama tetap tersedia, tetapi tidak membingungkan struktur aktif project.
