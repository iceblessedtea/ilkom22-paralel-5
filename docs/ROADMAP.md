# Roadmap

Roadmap ini memetakan langkah menuju kondisi _final_ project (lihat kriteria di [Project Overview](PROJECT_OVERVIEW.md#definisi-final--selesai)).

## Phase 1: Struktur dan Dokumentasi

Status: selesai.

- [x] Merapikan struktur folder.
- [x] Memisahkan folder aktif dan legacy.
- [x] Membuat dokumentasi tech stack.
- [x] Membuat dokumentasi arsitektur.
- [x] Membuat dokumentasi cara menjalankan project.
- [x] Menyiapkan folder observability.
- [x] Melengkapi dokumentasi environment dan API reference.

## Phase 2: Konfigurasi Runtime

- [x] Mengganti URL hardcoded antar-service menjadi environment variable.
- [x] Menyediakan `.env.example` yang konsisten (backend & frontend).
- [x] Membuat mode Docker dan non-Docker sama-sama valid.
- [x] Memastikan setiap service bisa dijalankan sendiri.
- [x] Menyediakan skrip start lokal lintas platform (`start-local.ps1` dan `start-local.sh`).

## Phase 3: OpenTelemetry

- [ ] Menambahkan gem OpenTelemetry ke setiap backend service.
- [ ] Mengaktifkan tracing untuk Sinatra/Rack.
- [ ] Mengaktifkan tracing untuk HTTP client.
- [ ] Mengirim trace ke OpenTelemetry Collector.
- [ ] Membuat contoh trace flow antar-service.
- [ ] (Opsional) Menambahkan backend visualisasi trace (Jaeger/Tempo).

## Phase 4: API dan Integrasi Frontend

- [ ] Menyusun ulang endpoint agar konsisten.
- [ ] Menambahkan dokumentasi API ([API Reference](API_REFERENCE.md)).
- [ ] Menghubungkan frontend ke backend services via `VITE_API_BASE_URL`.
- [ ] Menambahkan error handling dan loading state pada frontend.
- [ ] Menyamakan strategi CORS / penggunaan API Gateway.

## Phase 5: Testing dan Quality

- [ ] Menambahkan unit test (RSpec) untuk service utama.
- [ ] Menambahkan request spec untuk endpoint penting.
- [ ] Menambahkan test frontend (Vitest + React Testing Library).
- [ ] Menambahkan linting yang konsisten (RuboCop + ESLint/Prettier).
- [ ] Menambahkan smoke test untuk mode Docker dan non-Docker.
- [ ] (Opsional) Menyiapkan CI untuk menjalankan test otomatis.

## Phase 6: Database dan Deployment

- [ ] Merapikan migrasi database per service.
- [ ] Menentukan apakah SQLite tetap dipakai atau migrasi ke PostgreSQL.
- [ ] Menyiapkan deployment guide.
- [ ] Menyiapkan backup/restore database.

## Definition of Done (Final)

Project dianggap selesai ketika seluruh checklist Phase 2–Phase 6 terpenuhi dan kriteria "Final / Selesai" di [Project Overview](PROJECT_OVERVIEW.md) tercentang semua, dengan dokumentasi yang akurat terhadap kondisi kode terkini.
