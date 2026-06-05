# Project Overview

Project ini adalah sistem layanan kesehatan sederhana yang dikembangkan dengan pendekatan _backend services_ (microservice-oriented), dilengkapi frontend web berbasis React.

## Domain Utama

- Manajemen data pasien.
- Manajemen data dokter.
- Manajemen jadwal dokter, ruangan, dan timeslot.
- Manajemen janji temu (appointment).
- Manajemen rekam medis.

## Komponen Sistem

### Backend

Empat service domain (Patient, Doctor, Appointment, Medical Record) berbasis Ruby + Sinatra, plus API Gateway Nginx. Setiap service memiliki database PostgreSQL sendiri dan saling berkomunikasi via HTTP.

### Frontend

Aplikasi React + TypeScript + Vite yang mengonsumsi REST API backend. Frontend mengakses backend melalui API Gateway (saat memakai Docker) atau langsung ke masing-masing service (saat non-Docker), dengan base URL yang dikonfigurasi melalui environment variable (lihat [Environment](ENVIRONMENT.md)).

## Karakter Project

Project ini bukan monolith penuh dan juga belum microservice produksi yang matang. Kondisi saat ini lebih tepat disebut _microservice-oriented application_: domain sudah dipisahkan ke beberapa service, tetapi masih membutuhkan perapian pada konfigurasi, komunikasi antar-service, dokumentasi, testing, dan observability.

## Target Pengembangan

- Bisa dijalankan dengan Docker maupun tanpa Docker.
- Memiliki struktur folder yang mudah dipahami.
- Memiliki dokumentasi arsitektur, environment, API, dan roadmap yang lengkap.
- Memakai OpenTelemetry untuk distributed tracing.
- Memiliki konfigurasi environment yang konsisten (tanpa URL hardcoded).
- Frontend terhubung penuh ke backend dengan error handling yang baik.

## Definisi "Final / Selesai"

Project dianggap final ketika seluruh kriteria berikut terpenuhi:

- [x] Semua service backend bisa dijalankan via Docker **dan** non-Docker tanpa perubahan kode.
- [x] Tidak ada URL antar-service yang hardcoded; semua via environment variable.
- [x] Tersedia `.env.example` yang konsisten untuk backend dan frontend.
- [x] Frontend terhubung ke seluruh endpoint backend dan menangani error.
- [x] OpenTelemetry tersedia di semua service dan trace antar-service dapat dikirim ke collector.
- [x] Tersedia unit test dan request spec untuk service utama, plus test frontend dasar.
- [x] Dokumentasi (overview, arsitektur, environment, running guide, API reference) lengkap dan akurat.
- [x] Tersedia panduan deployment dan strategi database PostgreSQL.

Lihat [Roadmap](ROADMAP.md) untuk pemetaan kriteria ini ke tiap fase.
