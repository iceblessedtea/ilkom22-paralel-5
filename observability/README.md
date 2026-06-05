# Observability dan OpenTelemetry

Folder ini disiapkan sebagai fondasi observability untuk backend services Ruby Sinatra pada project ini.

Tujuannya:

- Mendukung tracing antar-service dengan OpenTelemetry.
- Tetap bisa berjalan dengan Docker.
- Tetap bisa berjalan tanpa Docker, memakai Ruby/Bundler lokal.
- Memisahkan konfigurasi observability dari kode bisnis utama.

## Struktur

```text
observability/
  README.md
  NOTE.md
  docker-compose.otel.yml
  otel-collector-config.yaml
  ruby/
    otel.rb
```

## Mode Dengan Docker

Gunakan file compose tambahan ini bersama compose utama:

```powershell
cd services
docker compose -f docker-compose.yml -f ../observability/docker-compose.otel.yml up --build
```

Service Ruby tetap dijalankan dari Docker Compose utama, sedangkan OpenTelemetry Collector dijalankan dari compose tambahan.

Endpoint collector di jaringan Docker:

```text
http://otel-collector:4318
```

## Mode Tanpa Docker

Jalankan setiap service dengan Ruby/Bundler lokal.

Contoh:

```powershell
cd services/patient-service
bundle install
$env:OTEL_ENABLED="true"
$env:OTEL_SERVICE_NAME="patient-service"
$env:OTEL_EXPORTER_OTLP_ENDPOINT="http://localhost:4318"
bundle exec rackup --host 0.0.0.0 --port 7860
```

Collector dapat dijalankan dengan binary lokal:

```powershell
otelcol --config observability/otel-collector-config.yaml
```

Jika belum ingin menjalankan collector, set:

```powershell
$env:OTEL_ENABLED="false"
```

## Integrasi Ke Service Ruby

Tambahkan dependency berikut ke setiap Gemfile service yang ingin diobservasi:

```ruby
gem "opentelemetry-sdk"
gem "opentelemetry-exporter-otlp"
gem "opentelemetry-instrumentation-all"
```

Lalu di awal `config.ru`, tambahkan:

```ruby
if ENV.fetch("OTEL_ENABLED", "false") == "true"
  otel_config = File.expand_path("../../observability/ruby/otel", __dir__)
  otel_config = "/observability/ruby/otel" unless File.exist?("#{otel_config}.rb")
  require otel_config
  use(*OpenTelemetry::Instrumentation::Rack::Instrumentation.instance.middleware_args)
end
```

Untuk service di dalam folder `services/<nama-service>`, path relatif di atas akan mengarah ke konfigurasi bersama di folder `observability`.

## Service Name Yang Disarankan

```text
patient-service
doctor-service
appointment-service
medical-record-service
```

Dengan nama service berbeda, trace antar-service akan lebih mudah dibaca.
