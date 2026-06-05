# Frontend Design & Integration Pattern

Dokumen ini adalah **sumber kebenaran desain frontend** sekaligus **pola integrasi frontend ↔ backend**. Tujuannya: siapa pun (termasuk AI lain) yang ingin menyambungkan backend ke frontend cukup membaca dokumen ini + prototype `frontend-prototype.html`.

Prototype interaktif: lihat file `frontend-prototype.html` (single-file HTML, bisa dibuka langsung di browser).

## 1. Prinsip Desain

- **Bersih & modern**: banyak ruang putih, sudut membulat (radius 8–12px), bayangan halus, border tipis.
- **Fokus konten**: data (pasien, dokter, janji temu) selalu jadi elemen utama; chrome (sidebar/topbar) tenang.
- **Animasi halus, bukan ramai**: transisi cepat (140–360ms), easing `cubic-bezier(0.22, 1, 0.36, 1)`. Selalu hormati `prefers-reduced-motion`.
- **Konsisten**: semua warna, spacing, dan komponen memakai design token yang sama.

## 2. Design Tokens

Dipinjam dari sistem dasar (mendukung light & dark mode otomatis via `prefers-color-scheme`).

| Token                                                          | Nilai (light)            | Kegunaan                                      |
| -------------------------------------------------------------- | ------------------------ | --------------------------------------------- |
| `--notion-bg` / `--notion-bg-soft`                             | `#ffffff` / `#f9f9f8`    | Background app & kanvas                       |
| `--notion-surface`                                             | `#ffffff`                | Kartu, panel, sidebar                         |
| `--notion-text` / `--notion-text-soft`                         | `#191918` / `54% black`  | Teks utama / sekunder                         |
| `--notion-border-soft`                                         | `5% black`               | Garis pemisah                                 |
| `--notion-blue`                                                | `#2783de`                | Aksen utama, tombol primary, status terjadwal |
| `--notion-green-bg` / `--notion-orange-bg` / `--notion-red-bg` | pastel                   | Status badge                                  |
| `--notion-radius`                                              | `8px`                    | Radius standar                                |
| `--notion-shadow`                                              | bayangan dua-lapis halus | Elevasi kartu/panel                           |

Warna status (badge):

| Status                            | Warna  |
| --------------------------------- | ------ |
| Aktif / Tersedia / Selesai-sukses | hijau  |
| Terjadwal                         | biru   |
| Menunggu / Penuh                  | oranye |
| Batal                             | merah  |
| Netral                            | abu    |

## 3. Tipografi

- Font: system UI stack (`ui-sans-serif, -apple-system, "Segoe UI"…`).
- Ukuran: judul halaman 20px/700, judul section 16px/700, body 14–16px, caption 12–13px.
- Angka pada statistik memakai `font-variant-numeric: tabular-nums` agar rapi.

## 4. Struktur Layout (App Shell)

```text
+----------------------------------------------------------+
| Sidebar (248px) |  Topbar (judul + search + refresh)     |
|  - Brand         +--------------------------------------+
|  - Menu nav      |                                       |
|  - Sistem nav    |  Content                              |
|  - User card     |  (stat grid / panel tabel / states)   |
+----------------------------------------------------------+
```

- **Sidebar**: brand, grup menu (Dashboard, Pasien, Dokter, Janji Temu, Rekam Medis), grup sistem (Observability), kartu user. Nav aktif punya indikator biru yang "tumbuh" (animasi `navGrow`) dan hover geser halus.
- **Topbar**: sticky, background blur (`backdrop-filter`), judul + subjudul dinamis per view, search, tombol refresh.
- **Content**: view di-render dinamis; setiap pergantian view memakai animasi `fadeUp`.

## 5. Komponen Inti

| Komponen           | Kelas / pola                             | Catatan                                                             |
| ------------------ | ---------------------------------------- | ------------------------------------------------------------------- |
| Stat card          | `.notion-stat`                           | Angka count-up saat muncul, ikon + aksen warna                      |
| Data panel + tabel | `.panel > table`                         | Baris fade-in bertahap (stagger `animation-delay`), hover highlight |
| Status badge       | `.badge.green/blue/orange/red/gray`      | Titik berwarna + label                                              |
| Person cell        | `.person .dot`                           | Avatar inisial berwarna deterministik                               |
| Skeleton loading   | `.skeleton`                              | Shimmer saat fetch                                                  |
| Empty state        | `.state` (emoji 📭)                      | Saat data kosong                                                    |
| Error state        | `.state` (emoji ⚠️) + tombol "Coba lagi" | Saat fetch gagal                                                    |
| Toast              | `.toast`                                 | Notifikasi aksi, auto-hilang 2.4s                                   |
| Callout            | `.notion-callout`                        | Info / catatan integrasi                                            |

## 6. Animasi (ringkasan)

| Animasi           | Dipakai di                 | Durasi                  |
| ----------------- | -------------------------- | ----------------------- |
| `fadeUp`          | pergantian view, stat card | 360–420ms               |
| `rowIn` (stagger) | baris tabel                | 300ms, delay 45ms/baris |
| `shimmer`         | skeleton loading           | 1.3s loop               |
| count-up          | angka statistik            | ~0.5s                   |
| `navGrow`         | indikator nav aktif        | 220ms                   |
| `grow` (bar)      | trace bar observability    | 700ms                   |
| `toastIn` / `pop` | toast, empty/error icon    | 280–320ms               |

Semua otomatis dimatikan saat user mengaktifkan _reduce motion_.

## 7. Pola Integrasi Frontend ↔ Backend (WAJIB DIIKUTI)

Lapisan kode mengikuti urutan **CONFIG → ENDPOINTS → API CLIENT → STATE → RENDER**. Lihat `<script>` di prototype untuk implementasi penuh.

### 7.1 Config (dari environment)

Base URL **tidak pernah** hardcoded di komponen. Ambil dari env (Vite):

```ts
const CONFIG = {
  apiBaseUrl: import.meta.env.VITE_API_BASE_URL, // lihat docs/ENVIRONMENT.md
};
```

Di prototype statis dipakai `window.__CONFIG__.apiBaseUrl` sebagai pengganti.

### 7.2 Endpoints (cermin API_REFERENCE.md)

Satu objek peta endpoint, sinkron dengan [API Reference](API_REFERENCE.md):

```ts
const ENDPOINTS = {
  patients: { base: PATIENT_URL, list: "/patients" },
  doctors: { base: DOCTOR_URL, list: "/doctors" },
  appointments: { base: APPOINTMENT_URL, list: "/appointments" },
  records: { base: MEDICAL_RECORD_URL, list: "/medical-records" },
};
```

> Saat memakai **API Gateway** (Docker), ganti tiap `base` dengan satu `CONFIG.apiBaseUrl` + prefix path, sehingga semua request lewat satu origin (menghindari masalah CORS).

### 7.3 API client (satu pintu)

```ts
async function apiGet(resource: string) {
  const ep = ENDPOINTS[resource];
  const res = await fetch(ep.base + ep.list, {
    headers: { Accept: "application/json" },
  });
  if (!res.ok) throw new Error(`HTTP ${res.status} pada ${resource}`);
  return res.json();
}
```

Semua pemanggilan data lewat fungsi ini → mudah menambah header auth, retry, atau tracing di satu tempat.

### 7.4 State pattern di setiap view

Setiap view **wajib** menangani 4 keadaan:

1. **Loading** → tampilkan skeleton.
2. **Success** → render tabel/kartu (dengan animasi stagger).
3. **Empty** → tampilkan empty state.
4. **Error** → tampilkan error state + tombol "Coba lagi".

```text
render(view):
  show skeleton
  try { data = await apiGet(resource); data.length ? renderTable(data) : renderEmpty() }
  catch (e) { renderError(e.message) }
```

### 7.5 Kontrak data (yang diharapkan frontend)

Bentuk JSON minimum yang harus dikembalikan tiap endpoint agar tabel ter-render:

```jsonc
// GET /patients
[{ "id": 1, "name": "Andi Wijaya", "age": 34, "gender": "L", "status": "Aktif" }]

// GET /doctors
[{ "id": 1, "name": "dr. Hapsari", "specialty": "Umum", "room": "R-101", "status": "Tersedia" }]

// GET /appointments  (sudah diagregasi: nama pasien & dokter ikut)
[{ "id": 1, "patient_name": "Andi Wijaya", "doctor_name": "dr. Surya", "schedule": "05 Jun, 09:00", "status": "Terjadwal" }]

// GET /medical-records
[{ "id": 1, "patient_name": "Budi Santoso", "diagnosis": "Hipertensi", "date": "04 Jun 2026", "doctor_name": "dr. Surya" }]
```

> Catatan: nama field di atas adalah kontrak yang dipakai prototype. Jika backend memakai nama lain (mis. `nama` bukan `name`), sesuaikan salah satu sisi agar konsisten, lalu perbarui dokumen ini.

### 7.6 Cara mengganti mock → backend asli

Di prototype, set `CONFIG.useMock = false`. Setelah itu `apiGet` akan benar-benar memanggil backend. Tidak ada perubahan lain yang diperlukan di lapisan render — itulah inti polanya.

## 8. Peta ke Struktur Frontend Nyata

Saat dipindah ke `frontend/` (React + Vite), pola di atas menjadi:

```text
frontend/src/
  config.ts          # CONFIG (baca import.meta.env.VITE_API_BASE_URL)
  services/api.ts     # ENDPOINTS + apiGet (lapisan 7.2 & 7.3)
  hooks/useResource.ts# state loading/success/empty/error (lapisan 7.4)
  components/         # StatCard, DataTable, Badge, Skeleton, EmptyState, ErrorState, Toast
  pages/              # Dashboard, Patients, Doctors, Appointments, Records
```

Dengan mengikuti pemetaan ini, integrasi BE↔FE menjadi mekanis: tambah entri di `ENDPOINTS`, definisikan kontrak data, panggil `apiGet`, render dengan komponen yang sudah ada.
