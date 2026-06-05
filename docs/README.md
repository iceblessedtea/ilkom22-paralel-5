# Dokumentasi Project

Project ini adalah **Sistem Layanan Kesehatan (Healthcare)** sederhana yang dibangun dengan pendekatan _backend services_ (microservice-oriented) dan frontend React. Folder `docs/` ini berisi seluruh dokumentasi utama project, untuk sisi backend maupun frontend.

## Status Project

| Bagian        | Teknologi                                       | Status                |
| ------------- | ----------------------------------------------- | --------------------- |
| Backend       | Ruby + Sinatra (4 service domain + API Gateway) | Aktif dikembangkan    |
| Frontend      | React + TypeScript + Vite                       | Aktif dikembangkan    |
| Observability | OpenTelemetry (distributed tracing)             | Sedang diintegrasikan |
| Mode jalan    | Docker dan non-Docker                           | Didukung keduanya     |

## Urutan Baca yang Disarankan

1. [Project Overview](PROJECT_OVERVIEW.md) — tujuan, ruang lingkup, dan status project.
2. [Folder Structure](FOLDER_STRUCTURE.md) — struktur folder dan pemetaan nama lama ke baru.
3. [Tech Stack](TECH_STACK.md) — teknologi frontend, backend, database, dan observability.
4. [Architecture](ARCHITECTURE.md) — batas service, alur antar-service, dan diagram.
5. [Environment](ENVIRONMENT.md) — daftar environment variable dan contoh `.env`.
6. [Running Guide](RUNNING_GUIDE.md) — cara menjalankan (Docker & non-Docker, Windows/macOS/Linux).
7. [API Reference](API_REFERENCE.md) — daftar endpoint tiap service.
8. [Observability](OBSERVABILITY.md) — setup dan verifikasi OpenTelemetry.
9. [Roadmap](ROADMAP.md) — fase pengembangan dan _definition of done_.
10. [Frontend Design](FRONTEND_DESIGN.md) — design system + pola integrasi frontend ↔ backend.
11. [Technical Decisions](TECHNICAL_DECISIONS.md) — catatan keputusan teknis (ADR).

## Konvensi Dokumentasi

- Bahasa: Indonesia.
- Perintah terminal disediakan untuk **PowerShell (Windows)** dan **Bash (macOS/Linux)** bila relevan.
- Setiap perubahan keputusan teknis dicatat di [Technical Decisions](TECHNICAL_DECISIONS.md).
