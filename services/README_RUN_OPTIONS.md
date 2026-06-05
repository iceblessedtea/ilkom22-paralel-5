# Opsi Menjalankan Backend Services

Project ini disiapkan agar bisa berjalan dengan Docker maupun tanpa Docker.

## Dengan Docker

Jalankan dari folder `services`:

```powershell
docker compose up --build
```

Jika ingin sekaligus menyalakan OpenTelemetry Collector:

```powershell
docker compose -f docker-compose.yml -f ../observability/docker-compose.otel.yml up --build
```

Mode Docker memakai nama service Docker untuk komunikasi antar-service:

```text
patients
doctors
appointments
medical_records
```

## Tanpa Docker

Pastikan Ruby dan Bundler sudah terinstall.

Jalankan tiap service di terminal berbeda:

```powershell
cd services/patient-service
bundle install
bundle exec rackup --host 0.0.0.0 --port 7860
```

```powershell
cd services/doctor-service
bundle install
bundle exec rackup --host 0.0.0.0 --port 7861
```

```powershell
cd services/appointment-service
bundle install
bundle exec rackup --host 0.0.0.0 --port 7862
```

```powershell
cd services/medical-record-service
bundle install
bundle exec rackup --host 0.0.0.0 --port 7863
```

Mode tanpa Docker memakai `localhost` untuk komunikasi antar-service.

## OpenTelemetry

Untuk mengaktifkan OpenTelemetry, setiap service perlu:

1. Menambahkan gem OpenTelemetry di Gemfile.
2. Memuat file `observability/ruby/otel.rb`.
3. Mengatur `OTEL_SERVICE_NAME`.
4. Mengatur `OTEL_EXPORTER_OTLP_ENDPOINT`.

Contoh:

```powershell
$env:OTEL_ENABLED="true"
$env:OTEL_SERVICE_NAME="appointment-service"
$env:OTEL_EXPORTER_OTLP_ENDPOINT="http://localhost:4318"
```

Jika memakai Docker, environment variable ini sudah disiapkan di `observability/docker-compose.otel.yml`.
