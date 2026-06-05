# Technical Decisions

Dokumen ini mencatat keputusan teknis penting (Architecture Decision Records). Setiap keputusan baru sebaiknya ditambahkan dengan format yang sama.

## ADR-1: Docker Bersifat Opsional

**Keputusan:** Project harus bisa berjalan dengan Docker dan tanpa Docker.

**Alasan:**

- Docker memudahkan menjalankan banyak service sekaligus.
- Tanpa Docker memudahkan debugging service satu per satu.
- Tidak semua environment development siap menjalankan Docker.

**Konsekuensi:**

- URL antar-service tidak boleh hardcoded hanya untuk Docker.
- Environment variable harus menjadi sumber konfigurasi utama (lihat [Environment](ENVIRONMENT.md)).
- Dokumentasi harus menyediakan dua mode menjalankan project.

## ADR-2: Backend Menggunakan Sinatra

**Keputusan:** Backend tetap memakai Ruby Sinatra.

**Alasan:**

- Codebase saat ini sudah menggunakan Sinatra dan Rack.
- Sinatra cukup ringan untuk service kecil.
- Cocok untuk pembelajaran microservice.

**Konsekuensi:**

- Struktur project perlu dibuat lebih disiplin secara manual.
- Testing, config, dan observability perlu ditambahkan eksplisit.

## ADR-3: SQLite Untuk Development

**Keputusan:** SQLite tetap dipakai untuk development dan demo.

**Alasan:**

- Ringan.
- Mudah dijalankan.
- Tidak perlu database server tambahan.

**Konsekuensi:**

- Untuk produksi, perlu evaluasi database yang lebih kuat seperti PostgreSQL (lihat [Roadmap](ROADMAP.md) Phase 6).

## ADR-4: OpenTelemetry Sebagai Kebaruan

**Keputusan:** Project diarahkan memakai OpenTelemetry untuk observability.

**Alasan:**

- Cocok untuk arsitektur microservice.
- Memberikan nilai modern pada project.
- Membantu debugging request lintas service.

**Konsekuensi:**

- Setiap service perlu instrumentasi.
- Perlu OpenTelemetry Collector atau backend observability lain.

## ADR-5: Frontend React + Vite

**Keputusan:** Frontend memakai React + TypeScript + Vite, terpisah dari backend.

**Alasan:**

- Vite memberi dev server cepat dan build yang ringan.
- TypeScript meningkatkan keamanan tipe saat mengonsumsi API.
- Pemisahan FE/BE menjaga batas yang jelas dan memudahkan deployment terpisah.

**Konsekuensi:**

- Base URL API harus dikonfigurasi via `VITE_API_BASE_URL`.
- Perlu strategi CORS atau penggunaan API Gateway agar frontend dapat mengakses backend.

## ADR-6: Komunikasi Antar-Service via HTTP/JSON

**Keputusan:** Service berkomunikasi via HTTP REST dengan payload JSON.

**Alasan:**

- Sederhana, mudah di-debug, dan didukung penuh oleh tooling yang ada (HTTPX/Net::HTTP).
- Mudah diinstrumentasi oleh OpenTelemetry HTTP client.

**Konsekuensi:**

- Perlu standar timeout, retry, dan penanganan error antar-service.
- Kontrak API harus dijaga konsisten (lihat [API Reference](API_REFERENCE.md)).
