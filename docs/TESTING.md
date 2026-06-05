# Testing dan Quality

Phase 5 menyediakan test backend, test frontend, lint, smoke test, dan CI.

## Backend RSpec

Setiap backend service memiliki request spec pada folder `spec/`.

PowerShell:

```powershell
services/scripts/run-rspec.ps1
```

Bash:

```bash
bash services/scripts/run-rspec.sh
```

Test memakai SQLite terisolasi di `spec/tmp`. Database development tidak diubah.

Coverage awal:

- health endpoint semua service;
- list pasien;
- list dokter;
- collection appointment kosong;
- list medical record dengan patient name;
- unit test normalisasi HTTP response appointment service.

## Frontend

Frontend memakai Vitest, React Testing Library, dan jest-dom.

```bash
cd frontend
npm ci
npm test
npm run lint
npm run build
```

Test frontend memverifikasi:

- loading state;
- render data pasien dari API;
- error state ketika gateway gagal.

## Ruby Syntax Lint

PowerShell:

```powershell
services/scripts/lint-ruby.ps1
```

Bash:

```bash
bash services/scripts/lint-ruby.sh
```

Lint backend memakai `ruby -c` untuk file API, Rack config, dan OpenTelemetry config. Frontend memakai ESLint melalui `npm run lint`.

## Smoke Test Non-Docker

Jalankan semua backend service secara lokal pada port 7860-7863, lalu:

PowerShell:

```powershell
services/scripts/smoke-local.ps1
```

Bash:

```bash
bash services/scripts/smoke-local.sh
```

Script memeriksa health endpoint dan collection endpoint langsung ke tiap service.

## Smoke Test Docker

PowerShell:

```powershell
services/scripts/smoke-docker.ps1
```

Bash:

```bash
bash services/scripts/smoke-docker.sh
```

Script melakukan:

1. build dan start Docker Compose;
2. menunggu setiap endpoint gateway siap;
3. memeriksa endpoint `/api`;
4. memeriksa CORS preflight;
5. mematikan container melalui cleanup otomatis.

## Continuous Integration

Workflow GitHub Actions berada di `.github/workflows/quality.yml`.

Workflow berjalan pada push ke `main` dan pull request:

- frontend test, lint, dan production build;
- RSpec matrix untuk empat backend service;
- Ruby syntax lint;
- validasi Docker Compose biasa dan OpenTelemetry;
- Docker smoke test.
