# Observability

Observability adalah kebaruan utama yang disarankan untuk project ini.

Teknologi yang digunakan:

- OpenTelemetry (Ruby SDK).
- OpenTelemetry Collector.
- OTLP exporter.
- Instrumentasi Ruby untuk Sinatra/Rack dan HTTP client.

## Tujuan

Observability dipakai untuk melihat flow request antar-service.

Contoh flow:

```text
Appointment Service -> Patient Service
Appointment Service -> Doctor Service
Patient Service -> Medical Record Service
Doctor Service -> Appointment Service
```

Dengan distributed tracing, developer dapat mengetahui:

- Service mana yang lambat.
- Request mana yang gagal.
- Berapa lama komunikasi antar-service.
- Bagaimana request bergerak dari satu service ke service lain.

## Struktur Observability

```text
observability/
  docker-compose.otel.yml
  otel-collector-config.yaml
  ruby/
    otel.rb
```

## Environment Variable

| Variabel                      | Keterangan                              |
| ----------------------------- | --------------------------------------- |
| `OTEL_ENABLED`                | `true` untuk mengaktifkan instrumentasi |
| `OTEL_SERVICE_NAME`           | Nama service pada trace                 |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Endpoint OTLP collector                 |

Lihat [Environment](ENVIRONMENT.md) untuk daftar lengkap.

## Mode Docker

Collector dijalankan sebagai container:

```bash
cd services
docker compose -f docker-compose.yml -f ../observability/docker-compose.otel.yml up --build
```

Endpoint OTLP di dalam jaringan Docker:

```text
http://otel-collector:4318
```

## Mode Tanpa Docker

Collector bisa dijalankan sebagai binary lokal:

```bash
otelcol --config observability/otel-collector-config.yaml
```

Endpoint OTLP lokal:

```text
http://localhost:4318
```

## Target Integrasi Berikutnya

Setiap service perlu menambahkan dependency:

```ruby
gem "opentelemetry-sdk"
gem "opentelemetry-exporter-otlp"
gem "opentelemetry-instrumentation-all"
```

Lalu memuat konfigurasi:

```ruby
require_relative "../../observability/ruby/otel" if ENV.fetch("OTEL_ENABLED", "false") == "true"
```

## Verifikasi

1. Set `OTEL_ENABLED=true` di service yang ingin di-trace.
2. Jalankan collector (mode Docker atau lokal).
3. Lakukan request, misalnya `GET /appointments` (yang memanggil Patient & Doctor Service).
4. Periksa log collector atau backend tracing (misalnya Jaeger/Tempo) untuk melihat trace lintas service yang saling terhubung dalam satu trace ID.

> Untuk visualisasi trace, collector dapat diarahkan ke backend seperti Jaeger atau Grafana Tempo. Penambahan backend visualisasi direkomendasikan pada [Roadmap](ROADMAP.md) Phase 3.
