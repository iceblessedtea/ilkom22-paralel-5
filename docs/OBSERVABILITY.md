# Observability

Observability adalah kebaruan utama yang disarankan untuk project ini.

Teknologi yang digunakan:

- OpenTelemetry Ruby SDK.
- OpenTelemetry Collector.
- OTLP exporter.
- Instrumentasi Ruby untuk Sinatra/Rack dan Net::HTTP.
- Jaeger untuk visualisasi trace saat Docker observability digunakan.

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

| Variabel | Keterangan |
| --- | --- |
| `OTEL_ENABLED` | `true` untuk mengaktifkan instrumentasi |
| `OTEL_SERVICE_NAME` | Nama service pada trace |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Endpoint OTLP trace collector |

Lihat [Environment](ENVIRONMENT.md) untuk daftar lengkap.

## Mode Docker

Collector dan Jaeger dijalankan sebagai container:

```bash
cd services
docker compose -f docker-compose.yml -f ../observability/docker-compose.otel.yml up --build
```

Endpoint OTLP di dalam jaringan Docker:

```text
http://otel-collector:4318
```

Jaeger UI:

```text
http://localhost:16686
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

## Integrasi Service Ruby

Setiap service memakai dependency berikut:

```ruby
gem "opentelemetry-sdk"
gem "opentelemetry-exporter-otlp"
gem "opentelemetry-instrumentation-all"
```

Setiap `config.ru` memuat konfigurasi bersama dan memasang Rack middleware tracing:

```ruby
if ENV.fetch("OTEL_ENABLED", "false") == "true"
  otel_config = File.expand_path("../../observability/ruby/otel", __dir__)
  otel_config = "/observability/ruby/otel" unless File.exist?("#{otel_config}.rb")
  require otel_config
  use(*OpenTelemetry::Instrumentation::Rack::Instrumentation.instance.middleware_args)
end
```

## Verifikasi

1. Set `OTEL_ENABLED=true` di service yang ingin di-trace.
2. Jalankan collector mode Docker atau lokal.
3. Lakukan request, misalnya `GET /appointments`.
4. Periksa log collector atau buka Jaeger UI untuk melihat trace lintas service dalam satu trace ID.

Contoh alur trace tersedia di [Trace Flow Example](TRACE_FLOW_EXAMPLE.md).

Catatan: aplikasi Ruby memakai `OTEL_EXPORTER_OTLP_ENDPOINT` sebagai endpoint base. Exporter Ruby akan mengirim trace ke path OTLP traces yang sesuai.
