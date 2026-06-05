# Deployment Guide

Panduan ini menjelaskan deployment single-host menggunakan Docker Compose. Untuk production dengan kebutuhan high availability, gunakan managed PostgreSQL dan orchestrator seperti Kubernetes atau platform container terkelola.

## 1. Persiapan Host

Kebutuhan minimum:

- Linux server atau VM dengan Docker Engine 24+ dan Docker Compose v2.
- 2 CPU, RAM 4 GB, dan disk persisten 20 GB.
- Domain untuk frontend/API serta sertifikat TLS.
- Firewall yang hanya membuka port HTTP/HTTPS publik.

Clone release yang akan dipasang:

```bash
git clone https://github.com/iceblessedtea/ilkom22-paralel-5.git
cd ilkom22-paralel-5
git checkout <tag-or-commit>
```

## 2. Production Configuration

Nilai pada `services/docker-compose.yml` adalah default development. Sebelum production:

1. Ganti `POSTGRES_USER` dan `POSTGRES_PASSWORD`.
2. Perbarui seluruh `DATABASE_URL` dengan kredensial yang sama.
3. Hapus port mapping PostgreSQL `5432:5432` jika database tidak perlu diakses dari host.
4. Batasi CORS pada `services/api-gateway/nginx.conf`.
5. Letakkan secret pada secret manager atau environment platform, bukan di Git.

Validasi konfigurasi:

```bash
cd services
docker compose config
```

## 3. Deploy Backend

```bash
cd services
docker compose up -d --build
docker compose ps
```

Setiap backend menunggu PostgreSQL healthy, menjalankan migrasi Sequel, lalu memulai Rack server.

Verifikasi:

```bash
curl --fail http://localhost/api/health
curl --fail http://localhost/api/patients
curl --fail http://localhost/api/doctors
curl --fail http://localhost/api/appointments
curl --fail http://localhost/api/medical-records
```

## 4. Deploy Frontend

Build static assets dengan URL API production:

```bash
cd frontend
npm ci
VITE_API_BASE_URL=https://api.example.com npm run build
```

Publikasikan isi `frontend/dist` melalui Nginx, object storage static hosting, atau platform frontend. Arahkan `VITE_API_BASE_URL` ke API Gateway yang dapat diakses browser.

## 5. Observability

Jalankan backend dengan overlay observability:

```bash
cd services
docker compose \
  -f docker-compose.yml \
  -f ../observability/docker-compose.otel.yml \
  up -d --build
```

Pastikan service memakai:

```text
OTEL_ENABLED=true
OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4318
```

Jaeger tersedia pada port `16686` jika port tersebut dipublikasikan oleh konfigurasi observability.

## 6. Updating a Deployment

Gunakan commit atau tag yang eksplisit:

```bash
git fetch --tags
git checkout <new-tag-or-commit>
cd services
docker compose build
docker compose up -d
docker compose ps
```

Periksa log migrasi dan startup:

```bash
docker compose logs --tail=100 postgres
docker compose logs --tail=100 patient-service doctor-service appointment-service medical-record-service
```

## 7. Rollback

Rollback kode:

```bash
git checkout <previous-tag-or-commit>
cd services
docker compose build
docker compose up -d
```

Migrasi database tidak otomatis di-downgrade saat rollback aplikasi. Jika release baru mengubah skema secara tidak kompatibel, pulihkan backup yang dibuat sebelum deployment atau jalankan prosedur rollback migrasi yang sudah diuji.

## 8. Production Checklist

- Kredensial default sudah diganti.
- PostgreSQL tidak terekspos ke internet.
- TLS aktif pada endpoint publik.
- CORS dibatasi ke origin frontend.
- Backup otomatis aktif dan restore pernah diuji.
- Resource limit dan restart policy disesuaikan dengan platform.
- Endpoint health dipantau.
- Log dan trace dikirim ke penyimpanan terpusat.
- Release menggunakan tag atau commit immutable.

Prosedur operasional tersedia di [PostgreSQL Backup and Restore](DATABASE_BACKUP.md).
