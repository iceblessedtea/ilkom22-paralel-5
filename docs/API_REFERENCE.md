# API Reference

Dokumen ini adalah kontrak API untuk frontend dan integrasi antar-service.

## Base URL

Frontend memakai satu base URL:

```text
VITE_API_BASE_URL=http://localhost
```

Path publik melalui API Gateway selalu memakai prefix `/api`.

```text
http://localhost/api/patients
http://localhost/api/doctors
http://localhost/api/appointments
http://localhost/api/medical-records
```

Service langsung ke port masing-masing tetap tersedia untuk development dan kompatibilitas internal.

## Konvensi Umum

- Request body memakai `Content-Type: application/json`.
- Response memakai JSON.
- Error memakai format `{ "error": "pesan error" }`.
- Kode status umum: `200`, `201`, `204`, `400`, `404`, `500`.
- Collection endpoint mengembalikan array kosong (`[]`) ketika data belum ada.
- API Gateway menerima CORS preflight `OPTIONS`.

## API Gateway

| Method | Path          | Keterangan             |
| ------ | ------------- | ---------------------- |
| GET    | `/api/health` | Health API Gateway     |
| OPTIONS | `/api/*`     | CORS preflight browser |

## Patient

Gateway base path: `/api/patients`

Service langsung: `http://localhost:7860/patients`

| Method | Path                                | Keterangan                                             |
| ------ | ----------------------------------- | ------------------------------------------------------ |
| GET    | `/api/patients`                     | Daftar pasien                                          |
| GET    | `/api/patients/:id`                 | Detail pasien                                          |
| POST   | `/api/patients`                     | Tambah pasien                                          |
| PUT    | `/api/patients/:id`                 | Ubah data pasien                                       |
| DELETE | `/api/patients/:id`                 | Hapus pasien                                           |
| GET    | `/api/patients/:id/medical-records` | Rekam medis pasien dari Medical Record Service         |

Contoh response `GET /api/patients`:

```json
{
  "success": true,
  "patients": [
    {
      "id": 1,
      "name": "Andi Wijaya",
      "age": 34,
      "gender": "L",
      "address": "Kendari"
    }
  ]
}
```

## Doctor

Gateway base path:

- `/api/doctors`
- `/api/rooms`
- `/api/timeslots`
- `/api/schedules`

Service langsung: `http://localhost:7861`

| Method | Path                         | Keterangan                          |
| ------ | ---------------------------- | ----------------------------------- |
| GET    | `/api/doctors`               | Daftar dokter                       |
| GET    | `/api/doctors/:id`           | Detail dokter                       |
| POST   | `/api/doctors`               | Tambah dokter                       |
| PUT    | `/api/doctors/:id`           | Ubah data dokter                    |
| DELETE | `/api/doctors/:id`           | Hapus dokter                        |
| GET    | `/api/doctors/:id/schedules` | Jadwal dokter                       |
| GET    | `/api/rooms`                 | Daftar ruangan                      |
| GET    | `/api/rooms/:id`             | Detail ruangan                      |
| GET    | `/api/timeslots`             | Daftar timeslot                     |
| GET    | `/api/timeslots/:id`         | Detail timeslot                     |
| GET    | `/api/schedules`             | Daftar jadwal                       |
| GET    | `/api/schedules/:id`         | Detail jadwal                       |

Contoh response `GET /api/doctors`:

```json
[
  {
    "id": 1,
    "name": "dr. Hapsari",
    "specialization": "Umum"
  }
]
```

## Appointment

Gateway base path: `/api/appointments`

Service langsung: `http://localhost:7862/appointments`

| Method | Path                                  | Keterangan                              |
| ------ | ------------------------------------- | --------------------------------------- |
| GET    | `/api/appointments`                   | Daftar janji temu                       |
| GET    | `/api/appointments/:id`               | Detail janji temu                       |
| POST   | `/api/appointments`                   | Buat janji temu                         |
| PUT    | `/api/appointments/:id`               | Ubah catatan janji temu                 |
| DELETE | `/api/appointments/:id`               | Hapus janji temu                        |
| GET    | `/api/appointments?doctor_id=:id`     | Filter janji temu berdasarkan dokter    |
| GET    | `/api/appointments?patient_id=:id`    | Filter janji temu berdasarkan pasien    |
| GET    | `/api/appointments/by-doctor/:id`     | Alias filter berdasarkan dokter         |
| GET    | `/api/appointments/by-patient/:id`    | Alias filter berdasarkan pasien         |

Path lama `/appointments/doctor/:id` dan `/appointments/patients/:id` tetap diterima oleh service untuk kompatibilitas.

Contoh response `GET /api/appointments`:

```json
[
  {
    "appointment_id": 1,
    "patient_id": 1,
    "patient_name": "Andi Wijaya",
    "doctor_id": 2,
    "doctor_name": "dr. Hapsari",
    "date": "2026-06-05",
    "notes": "Kontrol rutin",
    "room_name": "R-101",
    "timeslot": {
      "day": "Jumat",
      "start_time": "09:00",
      "end_time": "10:00"
    }
  }
]
```

## Medical Record

Gateway base path: `/api/medical-records`

Service langsung: `http://localhost:7863/medical-records`

| Method | Path                       | Keterangan                                      |
| ------ | -------------------------- | ----------------------------------------------- |
| GET    | `/api/medical-records`     | Daftar rekam medis                              |
| GET    | `/api/medical-records/:id` | Detail rekam medis                              |
| POST   | `/api/medical-records`     | Tambah rekam medis                              |
| PUT    | `/api/medical-records/:id` | Ubah rekam medis                                |
| DELETE | `/api/medical-records/:id` | Hapus rekam medis                               |

Path lama `/medical_records` tetap diterima untuk kompatibilitas.

Contoh response `GET /api/medical-records`:

```json
[
  {
    "id": 1,
    "patient_id": 1,
    "patient_name": "Andi Wijaya",
    "diagnosis": "Hipertensi",
    "created_at": "2026-06-05 09:00:00 +0800",
    "updated_at": "2026-06-05 09:00:00 +0800"
  }
]
```

## Contoh Request

```bash
curl http://localhost/api/health
curl http://localhost/api/patients
curl "http://localhost/api/appointments?doctor_id=1"
```
