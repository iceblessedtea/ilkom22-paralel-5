# Roadmap

Roadmap ini memetakan langkah menuju kondisi final project.

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

Status: selesai.

- [x] Mengganti URL hardcoded antar-service menjadi environment variable.
- [x] Menyediakan `.env.example` yang konsisten untuk backend dan frontend.
- [x] Membuat mode Docker dan non-Docker sama-sama valid.
- [x] Memastikan setiap service bisa dijalankan sendiri.
- [x] Menyediakan skrip start lokal lintas platform (`start-local.ps1` dan `start-local.sh`).

## Phase 3: OpenTelemetry

Status: selesai.

- [x] Menambahkan gem OpenTelemetry ke setiap backend service.
- [x] Mengaktifkan tracing untuk Sinatra/Rack.
- [x] Mengaktifkan tracing untuk HTTP client.
- [x] Mengirim trace ke OpenTelemetry Collector.
- [x] Membuat contoh trace flow antar-service.
- [x] Menambahkan backend visualisasi trace Jaeger.

## Phase 4: API dan Integrasi Frontend

Status: selesai.

- [x] Menyusun ulang endpoint agar konsisten.
- [x] Menambahkan dokumentasi API.
- [x] Menghubungkan frontend ke backend services via `VITE_API_BASE_URL`.
- [x] Menambahkan error handling dan loading state pada frontend.
- [x] Menyamakan strategi CORS atau penggunaan API Gateway.

## Phase 5: Testing dan Quality

Status: selesai.

- [x] Menambahkan unit test RSpec untuk service utama.
- [x] Menambahkan request spec untuk endpoint penting.
- [x] Menambahkan test frontend dengan Vitest dan React Testing Library.
- [x] Menambahkan linting yang konsisten.
- [x] Menambahkan smoke test untuk mode Docker dan non-Docker.
- [x] Menyiapkan CI untuk menjalankan test otomatis.

## Phase 6: Database dan Deployment

Status: selesai.

- [x] Merapikan migrasi database per service.
- [x] Migrasi dari SQLite ke PostgreSQL.
- [x] Menyiapkan deployment guide.
- [x] Menyiapkan backup/restore database.

## Definition of Done

Project dianggap selesai ketika Phase 2 sampai Phase 6 terpenuhi, dokumentasi akurat terhadap kode terkini, dan aplikasi bisa dijalankan serta diverifikasi dalam mode Docker maupun non-Docker.
