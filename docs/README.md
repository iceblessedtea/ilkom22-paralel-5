# Dokumentasi Project

Project ini adalah **Sistem Layanan Kesehatan (Healthcare)** sederhana yang dibangun dengan pendekatan backend services (microservice-oriented) dan frontend React.

## Status Project

| Bagian | Teknologi | Status |
| --- | --- | --- |
| Backend | Ruby + Sinatra (4 service domain + API Gateway) | Aktif dikembangkan |
| Frontend | React + TypeScript + Vite | Aktif dikembangkan |
| Observability | OpenTelemetry + Jaeger | Aktif |
| Mode jalan | Docker dan non-Docker | Didukung keduanya |

## Urutan Baca yang Disarankan

1. [Project Overview](PROJECT_OVERVIEW.md) - tujuan, ruang lingkup, dan status project.
2. [Folder Structure](FOLDER_STRUCTURE.md) - struktur folder dan pemetaan nama lama ke baru.
3. [Tech Stack](TECH_STACK.md) - teknologi frontend, backend, database, dan observability.
4. [Architecture](ARCHITECTURE.md) - batas service, alur antar-service, dan diagram.
5. [Environment](ENVIRONMENT.md) - daftar environment variable dan contoh `.env`.
6. [Running Guide](RUNNING_GUIDE.md) - cara menjalankan Docker dan non-Docker.
7. [Deployment Guide](DEPLOYMENT.md) - deployment, update, rollback, dan checklist production.
8. [API Reference](API_REFERENCE.md) - daftar endpoint tiap service.
9. [Observability](OBSERVABILITY.md) - setup dan verifikasi OpenTelemetry.
10. [Trace Flow Example](TRACE_FLOW_EXAMPLE.md) - contoh alur trace antar-service.
11. [Testing dan Quality](TESTING.md) - RSpec, Vitest, lint, smoke test, dan CI.
12. [Roadmap](ROADMAP.md) - fase pengembangan dan definition of done.
13. [Frontend Design](FRONTEND_DESIGN.md) - design system dan pola integrasi frontend ke backend.
14. [Technical Decisions](TECHNICAL_DECISIONS.md) - catatan keputusan teknis.

## Konvensi Dokumentasi

- Bahasa: Indonesia.
- Perintah terminal disediakan untuk PowerShell dan Bash bila relevan.
- Setiap perubahan keputusan teknis dicatat di [Technical Decisions](TECHNICAL_DECISIONS.md).
