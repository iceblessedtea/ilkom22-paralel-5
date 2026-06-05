# Trace Flow Example

Dokumen ini memberi contoh alur trace yang diharapkan setelah Phase 3 OpenTelemetry aktif.

## Menjalankan Stack Dengan Observability

```powershell
cd services
docker compose -f docker-compose.yml -f ../observability/docker-compose.otel.yml up --build
```

Jaeger UI:

```text
http://localhost:16686
```

## Contoh Flow Appointment

Request:

```bash
curl http://localhost:7862/appointments
```

Trace yang diharapkan:

```text
GET /appointments
  appointment-service
    Net::HTTP GET patient-service /patients/:id
      patient-service
    Net::HTTP GET doctor-service /doctors/:id
      doctor-service
    Net::HTTP GET doctor-service /schedules
      doctor-service
    Net::HTTP GET doctor-service /timeslots
      doctor-service
    Net::HTTP GET doctor-service /rooms
      doctor-service
```

## Contoh Flow Rekam Medis

Request:

```bash
curl http://localhost:7860/patients/1/medical-records
```

Trace yang diharapkan:

```text
GET /patients/1/medical-records
  patient-service
    Net::HTTP GET medical-record-service /medical_records/1
      medical-record-service
```

## Cara Membaca

- Root span menunjukkan endpoint pertama yang dipanggil client.
- Child span menunjukkan panggilan HTTP antar-service.
- Service name harus tampil sebagai `patient-service`, `doctor-service`, `appointment-service`, dan `medical-record-service`.
- Jika hanya root span yang muncul, cek apakah HTTP client yang digunakan sudah terinstrumentasi.
- Jika span tidak muncul sama sekali, cek `OTEL_ENABLED=true` dan `OTEL_EXPORTER_OTLP_ENDPOINT`.

