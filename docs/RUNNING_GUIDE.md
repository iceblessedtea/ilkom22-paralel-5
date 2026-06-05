# Running Guide

Project ini dirancang agar dapat dijalankan dengan Docker maupun tanpa Docker.

## Prasyarat

| Mode                  | Kebutuhan                                          |
| --------------------- | -------------------------------------------------- |
| Docker                | Docker Desktop / Docker Engine + Docker Compose v2 |
| Non-Docker (backend)  | Ruby 3.3, Bundler, PostgreSQL 16                   |
| Non-Docker (frontend) | Node.js 18+ dan npm                                |
| Observability (lokal) | Binary `otelcol` (opsional, jika tanpa Docker)     |

Semua perintah disediakan untuk **PowerShell (Windows)** dan **Bash (macOS/Linux)**.

## 1. Setup Environment

Salin file contoh environment sebelum menjalankan (lihat [Environment](ENVIRONMENT.md)):

PowerShell:

```powershell
Copy-Item services/patient-service/.env.example services/patient-service/.env
Copy-Item services/doctor-service/.env.example services/doctor-service/.env
Copy-Item services/appointment-service/.env.example services/appointment-service/.env
Copy-Item services/medical-record-service/.env.example services/medical-record-service/.env
Copy-Item frontend/.env.example frontend/.env
```

Bash:

```bash
cp services/patient-service/.env.example services/patient-service/.env
cp services/doctor-service/.env.example services/doctor-service/.env
cp services/appointment-service/.env.example services/appointment-service/.env
cp services/medical-record-service/.env.example services/medical-record-service/.env
cp frontend/.env.example frontend/.env
```

Untuk Docker, file `.env` per service tidak wajib karena `services/docker-compose.yml` sudah menyetel environment utama.

## 2. Menjalankan dengan Docker

Jalankan semua backend services:

```bash
cd services
docker compose up --build
```

Jalankan backend services + OpenTelemetry Collector:

```bash
cd services
docker compose -f docker-compose.yml -f ../observability/docker-compose.otel.yml up --build
```

Endpoint utama:

```text
Patient Service:        http://localhost:7860
Doctor Service:         http://localhost:7861
Appointment Service:    http://localhost:7862
Medical Record Service: http://localhost:7863
API Gateway:            http://localhost
```

## 3. Menjalankan tanpa Docker (Backend)

Pastikan Ruby, Bundler, dan PostgreSQL tersedia. Buat database berikut sebelum menjalankan service:

```text
patient_service
doctor_service
appointment_service
medical_record_service
```

Jalankan tiap service di terminal terpisah. Migrasi harus dijalankan sebelum Rack:

PowerShell:

```powershell
cd services/patient-service
bundle install
bundle exec ruby db/migrate.rb
bundle exec rackup --host 0.0.0.0 --port 7860
```

Bash:

```bash
cd services/patient-service
bundle install
bundle exec ruby db/migrate.rb
bundle exec rackup --host 0.0.0.0 --port 7860
```

Lakukan hal yang sama untuk service lain dengan port masing-masing:

```text
doctor-service          -> 7861
appointment-service     -> 7862
medical-record-service  -> 7863
```

Atau gunakan helper PowerShell:

```powershell
services/scripts/start-local.ps1
```

Dengan OpenTelemetry:

```powershell
services/scripts/start-local.ps1 -WithOtel
```

Helper Bash/macOS/Linux:

```bash
services/scripts/start-local.sh
```

Dengan OpenTelemetry:

```bash
services/scripts/start-local.sh --with-otel
```

## 4. Menjalankan Frontend

```bash
cd frontend
npm install
npm run dev
```

Frontend membaca base URL backend dari `VITE_API_BASE_URL` (lihat [Environment](ENVIRONMENT.md)). Default development mengarah ke API Gateway di `http://localhost`, dan semua request frontend memakai path `/api/...`.

## 5. Menjalankan Test

Backend seluruh service:

```powershell
services/scripts/run-rspec.ps1
```

```bash
bash services/scripts/run-rspec.sh
```

Frontend test, lint, dan build:

```bash
cd frontend
npm test
npm run lint
npm run build
```

Smoke test:

```powershell
services/scripts/smoke-local.ps1
services/scripts/smoke-docker.ps1
```

```bash
bash services/scripts/smoke-local.sh
bash services/scripts/smoke-docker.sh
```

Panduan lengkap tersedia di [Testing dan Quality](TESTING.md).

## Troubleshooting

- **Port sudah dipakai**: ubah `PORT` di `.env` service terkait, atau hentikan proses yang memakai port.
- **Service tidak bisa memanggil service lain (non-Docker)**: pastikan variabel `*_URL` mengarah ke `http://localhost:<port>`, bukan nama container Docker.
- **Frontend gagal fetch (CORS)**: pastikan backend dijalankan melalui API Gateway dan `VITE_API_BASE_URL` mengarah ke host gateway.
- **Trace tidak muncul**: pastikan `OTEL_ENABLED=true` dan `OTEL_EXPORTER_OTLP_ENDPOINT` mengarah ke collector yang aktif.
- **Koneksi PostgreSQL gagal**: pastikan database sudah dibuat dan `DATABASE_URL` memakai host, user, password, serta nama database yang benar.

## Catatan

Jika Ruby/Bundler belum tersedia di mesin lokal, mode Docker adalah opsi tercepat untuk menjalankan seluruh sistem.
