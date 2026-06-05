# API Reference

> Catatan: dokumen ini adalah tambahan baru untuk melengkapi doc set (sebelumnya hanya dijanjikan di Roadmap Phase 4). Sesuaikan path endpoint dengan implementasi aktual di tiap service, lalu jadikan dokumen ini sumber kebenaran kontrak API.

Semua service mengembalikan dan menerima JSON. Base URL mengikuti [Environment](ENVIRONMENT.md): langsung ke port service (non-Docker) atau melalui API Gateway (Docker).

## Konvensi Umum

- `Content-Type: application/json` untuk request dengan body.
- Kode status: `200` OK, `201` Created, `204` No Content, `400` Bad Request, `404` Not Found, `422` Unprocessable Entity, `500` Internal Server Error.
- Format error yang disarankan:

```json
{ "error": "pesan error yang jelas" }
```

## Health Check (semua service)

```text
GET /health  ->  200 { "status": "ok", "service": "<nama-service>" }
```

## Patient Service (`:7860`)

| Method | Path                            | Keterangan                                             |
| ------ | ------------------------------- | ------------------------------------------------------ |
| GET    | `/patients`                     | Daftar pasien                                          |
| GET    | `/patients/:id`                 | Detail pasien                                          |
| POST   | `/patients`                     | Tambah pasien                                          |
| PUT    | `/patients/:id`                 | Ubah data pasien                                       |
| DELETE | `/patients/:id`                 | Hapus pasien                                           |
| GET    | `/patients/:id/medical-records` | Rekam medis pasien (ambil dari Medical Record Service) |

## Doctor Service (`:7861`)

| Method | Path                     | Keterangan                          |
| ------ | ------------------------ | ----------------------------------- |
| GET    | `/doctors`               | Daftar dokter                       |
| GET    | `/doctors/:id`           | Detail dokter                       |
| POST   | `/doctors`               | Tambah dokter                       |
| PUT    | `/doctors/:id`           | Ubah data dokter                    |
| DELETE | `/doctors/:id`           | Hapus dokter (cek appointment dulu) |
| GET    | `/doctors/:id/schedules` | Jadwal dokter                       |
| GET    | `/rooms`                 | Daftar ruangan                      |
| GET    | `/timeslots`             | Daftar timeslot                     |

## Appointment Service (`:7862`)

| Method | Path                | Keterangan                                          |
| ------ | ------------------- | --------------------------------------------------- |
| GET    | `/appointments`     | Daftar janji temu (dengan agregasi pasien & dokter) |
| GET    | `/appointments/:id` | Detail janji temu                                   |
| POST   | `/appointments`     | Buat janji temu                                     |
| PUT    | `/appointments/:id` | Ubah janji temu                                     |
| DELETE | `/appointments/:id` | Batalkan janji temu                                 |

## Medical Record Service (`:7863`)

| Method | Path                   | Keterangan                                              |
| ------ | ---------------------- | ------------------------------------------------------- |
| GET    | `/medical-records`     | Daftar rekam medis                                      |
| GET    | `/medical-records/:id` | Detail rekam medis                                      |
| POST   | `/medical-records`     | Tambah rekam medis (validasi pasien ke Patient Service) |
| PUT    | `/medical-records/:id` | Ubah rekam medis                                        |
| DELETE | `/medical-records/:id` | Hapus rekam medis                                       |

> Catatan kompatibilitas: Medical Record Service juga masih menerima path lama `/medical_records` agar klien lama tidak langsung rusak.

## Contoh Request

Membuat janji temu:

```bash
curl -X POST http://localhost:7862/appointments \
  -H "Content-Type: application/json" \
  -d '{ "patient_id": 1, "doctor_id": 2, "timeslot_id": 5 }'
```
