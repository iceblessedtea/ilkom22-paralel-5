# Frontend Design & Integration Pattern

Dokumen ini menjadi rujukan desain dan pola integrasi frontend React dengan backend microservice.

## Prinsip Desain

- UI bersih, padat, dan operasional.
- Data pasien, dokter, janji temu, dan rekam medis menjadi elemen utama.
- Layout memakai app shell: sidebar navigasi, topbar, ringkasan statistik, dan panel tabel.
- State data selalu eksplisit: loading, success, empty, dan error.
- API base URL tidak hardcoded di komponen.

## Struktur Frontend

```text
frontend/src/
  config.ts
  services/api.ts
  hooks/useResource.ts
  App.tsx
  App.css
  index.css
```

## Environment

Frontend membaca satu variabel Vite:

```ts
const apiBaseUrl = import.meta.env.VITE_API_BASE_URL || "http://localhost";
```

Default `frontend/.env.example`:

```text
VITE_API_BASE_URL=http://localhost
```

Nilai tersebut mengarah ke API Gateway. Semua request frontend memakai prefix `/api`.

## Endpoint Frontend

Peta endpoint berada di `frontend/src/services/api.ts`.

| Resource       | Path API Gateway        |
| -------------- | ----------------------- |
| Pasien         | `/api/patients`         |
| Dokter         | `/api/doctors`          |
| Janji Temu     | `/api/appointments`     |
| Rekam Medis    | `/api/medical-records`  |

Kontrak lengkap ada di [API Reference](API_REFERENCE.md).

## API Client

Semua request data melewati `apiGet`.

- Menambahkan header `Accept: application/json`.
- Mengubah `404` pada collection menjadi array kosong.
- Membaca pesan error dari response `{ "error": "..." }`.
- Menormalisasi response Patient Service yang masih berbentuk `{ success, patients }`.

## State Pattern

Hook `useResource` menangani:

- `loading`: tampil skeleton rows.
- `error`: tampil error state dengan tombol coba lagi.
- `empty`: tampil empty state ketika collection kosong.
- `success`: tampil tabel data.

## Data Minimal yang Dipakai UI

```json
{
  "patients": [{ "id": 1, "name": "Andi", "age": 34, "gender": "L", "address": "Kendari" }],
  "doctors": [{ "id": 1, "name": "dr. Hapsari", "specialization": "Umum" }],
  "appointments": [{ "appointment_id": 1, "patient_name": "Andi", "doctor_name": "dr. Hapsari", "date": "2026-06-05" }],
  "medicalRecords": [{ "id": 1, "patient_name": "Andi", "diagnosis": "Hipertensi", "created_at": "2026-06-05" }]
}
```

Jika backend menambah field baru, update normalizer di `services/api.ts` dan kontrak di [API Reference](API_REFERENCE.md).
