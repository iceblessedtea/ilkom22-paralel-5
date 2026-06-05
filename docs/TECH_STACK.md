# Tech Stack

## Frontend

- React 18
- TypeScript 5
- Vite
- ESLint (+ Prettier disarankan untuk formatting konsisten)
- Vitest + React Testing Library (untuk testing, lihat [Roadmap](ROADMAP.md) Phase 5)

Lokasi:

```text
frontend/
```

Frontend mengakses backend melalui base URL yang dikonfigurasi via environment variable Vite (`VITE_API_BASE_URL`). Lihat [Environment](ENVIRONMENT.md).

## Backend

- Ruby (disarankan 3.2+)
- Sinatra
- Rack / Rackup
- Sequel (ORM)
- SQLite
- HTTPX dan Net::HTTP untuk komunikasi antar-service
- Puma sebagai app server (digunakan pada Appointment Service; disarankan diseragamkan ke semua service)
- RSpec + Rack::Test (untuk unit test & request spec, lihat [Roadmap](ROADMAP.md) Phase 5)

Lokasi:

```text
services/
```

## Backend Services

| Service                | Folder                            | Port   | Tanggung Jawab                                  |
| ---------------------- | --------------------------------- | ------ | ----------------------------------------------- |
| Patient Service        | `services/patient-service`        | `7860` | Data pasien                                     |
| Doctor Service         | `services/doctor-service`         | `7861` | Data dokter, ruangan, timeslot, jadwal          |
| Appointment Service    | `services/appointment-service`    | `7862` | Data janji temu dan agregasi data pasien/dokter |
| Medical Record Service | `services/medical-record-service` | `7863` | Data rekam medis                                |
| API Gateway            | `services/api-gateway`            | `80`   | Reverse proxy Nginx saat Docker digunakan       |

## Database

Project saat ini memakai SQLite per service.

**Keuntungan**

- Ringan untuk development.
- Mudah dipakai untuk demo.
- Tidak wajib menjalankan database server terpisah.

**Keterbatasan**

- Kurang ideal untuk concurrent write skala besar.
- Migrasi dan backup perlu dirapikan.
- Untuk produksi, lebih baik dipertimbangkan PostgreSQL atau MySQL.

Keputusan database untuk produksi dibahas di [Technical Decisions](TECHNICAL_DECISIONS.md) dan [Roadmap](ROADMAP.md) Phase 6.

## Container dan Runtime

Docker bersifat opsional.

**Docker digunakan untuk:**

- Menjalankan semua backend service sekaligus.
- Menjalankan API Gateway.
- Menjalankan OpenTelemetry Collector.

**Tanpa Docker digunakan untuk:**

- Development lokal.
- Debugging service satu per satu.
- Demo sederhana.

## Observability

Kebaruan utama project adalah OpenTelemetry.

**Komponen**

- OpenTelemetry Ruby SDK (`opentelemetry-sdk`).
- OpenTelemetry instrumentation (`opentelemetry-instrumentation-all`).
- OTLP exporter (`opentelemetry-exporter-otlp`).
- OpenTelemetry Collector.

**Manfaat**

- Distributed tracing.
- Monitoring latency antar-service.
- Analisis error lintas service.
- Pemahaman flow request end-to-end.

Detail setup ada di [Observability](OBSERVABILITY.md).
