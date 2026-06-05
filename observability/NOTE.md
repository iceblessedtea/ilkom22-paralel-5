# Note Pengembangan Project

Project ini dapat dijelaskan sebagai aplikasi layanan kesehatan berbasis backend services/microservice.

Framework utama:

- Backend: Ruby Sinatra dengan Rack.
- Database: SQLite per service.
- ORM/query builder: Sequel.
- Frontend: React, TypeScript, dan Vite.
- Gateway opsional: Nginx.
- Container opsional: Docker Compose.
- Observability baru: OpenTelemetry.

## Prinsip Pengembangan

Project ini sebaiknya tidak dibuat bergantung penuh pada Docker.

Docker tetap boleh digunakan untuk:

- Menjalankan semua service sekaligus.
- Menyamakan environment antar anggota tim.
- Menjalankan Nginx gateway.
- Menjalankan OpenTelemetry Collector.

Tanpa Docker tetap harus bisa digunakan untuk:

- Development lokal.
- Debug service satu per satu.
- Presentasi atau demo sederhana.
- Kondisi laptop yang belum siap menjalankan Docker.

## Kebaruan Yang Ditambahkan

Kebaruan yang disarankan adalah observability menggunakan OpenTelemetry.

OpenTelemetry memberi kemampuan untuk melihat alur request antar-service, misalnya:

```text
client -> appointment-service -> patient-service
client -> appointment-service -> doctor-service
patient-service -> medical-record-service
```

Manfaatnya:

- Melihat service mana yang lambat.
- Melacak error lintas service.
- Memahami dependensi antar-service.
- Membuat project lebih modern karena sudah menerapkan distributed tracing.

## Catatan Penting Non-Docker

Beberapa URL service di kode saat ini masih memakai nama container Docker, seperti:

```text
http://patient-service:7860
http://doctor-service:7861
http://appointment-service:7862
http://medical-record-service:7863
```

Agar bisa berjalan tanpa Docker, URL tersebut sebaiknya dibuat configurable lewat environment variable.

Contoh pola:

```ruby
PATIENT_URL = ENV.fetch("PATIENT_URL", "http://localhost:7860")
DOCTOR_URL = ENV.fetch("DOCTOR_URL", "http://localhost:7861")
```

Saat Docker:

```text
PATIENT_URL=http://patient-service:7860
DOCTOR_URL=http://doctor-service:7861
```

Saat tanpa Docker:

```text
PATIENT_URL=http://localhost:7860
DOCTOR_URL=http://localhost:7861
```
