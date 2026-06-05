# PostgreSQL Backup and Restore

Project menyediakan script PowerShell dan Bash untuk membackup empat database domain:

- `patient_service`
- `doctor_service`
- `appointment_service`
- `medical_record_service`

Backup menggunakan plain SQL dari `pg_dump` dengan `--clean --if-exists`. Setiap eksekusi membuat folder timestamp dan `manifest.json`.

## Backup

PowerShell:

```powershell
services\scripts\backup-databases.ps1
```

Bash:

```bash
bash services/scripts/backup-databases.sh
```

Output default:

```text
services/backups/<timestamp>/
|-- patient_service.sql
|-- doctor_service.sql
|-- appointment_service.sql
|-- medical_record_service.sql
`-- manifest.json
```

Gunakan lokasi lain:

```powershell
services\scripts\backup-databases.ps1 -OutputDirectory D:\healthcare-backups
```

```bash
bash services/scripts/backup-databases.sh /var/backups/healthcare
```

## Restore

Restore seluruh database:

```powershell
services\scripts\restore-databases.ps1 `
  -BackupDirectory services\backups\<timestamp>
```

```bash
bash services/scripts/restore-databases.sh \
  services/backups/<timestamp>
```

Restore satu database:

```powershell
services\scripts\restore-databases.ps1 `
  -BackupDirectory services\backups\<timestamp> `
  -Database patient_service
```

```bash
bash services/scripts/restore-databases.sh \
  services/backups/<timestamp> patient_service
```

Restore membersihkan objek database yang tercantum dalam dump lalu membuat ulang skema dan data. Hentikan traffic write selama proses restore untuk menghindari data baru tertimpa.

## Verification

Periksa tabel dan jumlah data:

```powershell
cd services
docker compose exec postgres `
  psql -U healthcare -d patient_service `
  -c "SELECT count(*) FROM patients;"
```

Lakukan restore drill secara berkala pada environment non-production:

1. Buat backup terbaru.
2. Catat jumlah row penting.
3. Restore backup ke database test atau environment staging.
4. Jalankan migrasi dan smoke test.
5. Bandingkan jumlah row dan lakukan request API.

## Operational Recommendations

- Simpan backup di storage terpisah dari host aplikasi.
- Enkripsi backup saat disimpan dan dikirim.
- Terapkan retention harian, mingguan, dan bulanan.
- Batasi akses file backup karena dapat memuat data sensitif.
- Monitor exit code dan ukuran file backup.
- Backup sebelum deployment yang mengubah skema.
