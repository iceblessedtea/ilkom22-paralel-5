# Environment

Project memakai environment variable sebagai sumber konfigurasi utama, agar mode Docker dan non-Docker sama-sama valid tanpa mengubah kode. Dokumen ini adalah referensi lengkap variabel yang dipakai backend dan frontend.

> Catatan: dokumen ini adalah tambahan baru untuk melengkapi doc set. Sediakan file `.env.example` di tiap service dan di `frontend/` sesuai contoh di bawah.

## Backend (per service)

| Variabel                      | Default (non-Docker)       | Keterangan                                               |
| ----------------------------- | -------------------------- | -------------------------------------------------------- |
| `PORT`                        | sesuai service (7860-7863) | Port tempat service berjalan                             |
| `RACK_ENV`                    | `development`              | Environment Rack (`development` / `production` / `test`) |
| `DATABASE_URL`                | PostgreSQL per service     | Connection URL database milik service                    |
| `POSTGRES_USER`               | `healthcare`               | User PostgreSQL untuk Docker Compose                      |
| `POSTGRES_PASSWORD`           | `healthcare`               | Password PostgreSQL; wajib diganti di production          |
| `PATIENT_URL`                 | `http://localhost:7860`    | Base URL Patient Service                                 |
| `DOCTOR_URL`                  | `http://localhost:7861`    | Base URL Doctor Service                                  |
| `APPOINTMENT_URL`             | `http://localhost:7862`    | Base URL Appointment Service                             |
| `MEDICAL_RECORD_URL`          | `http://localhost:7863`    | Base URL Medical Record Service                          |
| `OTEL_ENABLED`                | `false`                    | Aktifkan instrumentasi OpenTelemetry                     |
| `OTEL_SERVICE_NAME`           | nama service               | Nama service pada trace                                  |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | `http://localhost:4318`    | Endpoint base OTLP collector untuk exporter Ruby        |

### Contoh `.env.example` (non-Docker)

```text
PORT=7862
RACK_ENV=development
DATABASE_URL=postgres://healthcare:healthcare@localhost:5432/appointment_service
PATIENT_URL=http://localhost:7860
DOCTOR_URL=http://localhost:7861
APPOINTMENT_URL=http://localhost:7862
MEDICAL_RECORD_URL=http://localhost:7863
OTEL_ENABLED=false
OTEL_SERVICE_NAME=appointment-service
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318
```

PostgreSQL lokal harus memiliki database `patient_service`, `doctor_service`, `appointment_service`, dan `medical_record_service`. Docker Compose membuat database tersebut otomatis.

### Nilai untuk mode Docker

```text
PATIENT_URL=http://patient-service:7860
DOCTOR_URL=http://doctor-service:7861
APPOINTMENT_URL=http://appointment-service:7862
MEDICAL_RECORD_URL=http://medical-record-service:7863
OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4318
```

## Frontend

| Variabel            | Default                 | Keterangan                            |
| ------------------- | ----------------------- | ------------------------------------- |
| `VITE_API_BASE_URL` | `http://localhost` | Base URL API Gateway yang dikonsumsi frontend |

Frontend memakai path `/api/...` melalui API Gateway. Pada mode Docker, gunakan `VITE_API_BASE_URL=http://localhost`. Jika gateway dijalankan di host atau port lain, ubah nilai ini tanpa mengubah kode frontend.

### Contoh `frontend/.env.example`

```text
VITE_API_BASE_URL=http://localhost
```

## Prinsip

- Jangan commit file `.env` asli; commit hanya `.env.example`.
- Setiap penambahan variabel baru wajib ditambahkan ke `.env.example` dan ke dokumen ini.
- Nilai default harus aman untuk development lokal (non-Docker).

## File yang Tersedia

- `services/.env.example` untuk contoh konfigurasi backend secara umum.
- `services/patient-service/.env.example`
- `services/doctor-service/.env.example`
- `services/appointment-service/.env.example`
- `services/medical-record-service/.env.example`
- `frontend/.env.example`
