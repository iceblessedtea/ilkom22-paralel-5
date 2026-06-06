import { useEffect, useMemo, useState, type FormEvent } from 'react'
import './App.css'
import { CONFIG } from './config'
import { useResource, type ResourceItem } from './hooks/useResource'
import {
  ENDPOINTS,
  apiCreate,
  apiDelete,
  type Appointment,
  type CreatePayload,
  type Doctor,
  type MedicalRecord,
  type Patient,
  type ResourceKey,
} from './services/api'

type PageKey = 'home' | 'doctors' | 'services' | 'operations' | 'news'

const RESOURCE_ITEMS: Array<{ key: ResourceKey; label: string; description: string }> = [
  { key: 'patients', label: 'Pasien', description: 'Registrasi dan identitas pasien' },
  { key: 'doctors', label: 'Dokter', description: 'Tenaga medis dan spesialisasi' },
  { key: 'appointments', label: 'Janji Temu', description: 'Reservasi layanan rawat jalan' },
  { key: 'medicalRecords', label: 'Rekam Medis', description: 'Riwayat diagnosis pasien' },
]

const FEATURED_SERVICES = [
  ['Klinik Anggrek Eksekutif', 'Layanan prioritas untuk pasien umum dan asuransi.'],
  ['Medical Check Up', 'Skrining kesehatan terpadu berbasis data pasien.'],
  ['Rawat Inap', 'Koordinasi kasur, dokter, dan rekam medis dalam satu sistem.'],
  ['Intensive Care', 'Monitoring pasien kritis dengan alur data cepat.'],
  ['Instalasi Gawat Darurat', 'Registrasi dan respons triage untuk kondisi darurat.'],
  ['Laboratorium', 'Dukungan pemeriksaan klinis untuk diagnosis dokter.'],
]

const EXCELLENCE_CARDS = [
  ['Klinik Anak', 'Pelayanan anak terpadu dengan pendekatan multidisiplin.'],
  ['Jantung dan Pembuluh Darah', 'Penanganan kardiovaskular dengan fasilitas modern.'],
  ['Obstetri dan Ginekologi', 'Layanan kebidanan dan kandungan untuk keluarga.'],
]

const NEWS_ITEMS = [
  ['Layanan Stem Cell Orthopaedi', 'Inovasi layanan regeneratif untuk gangguan muskuloskeletal.'],
  ['Promo MCU Metabolik', 'Paket skrining kesehatan untuk deteksi risiko sejak dini.'],
  ['RS Pendidikan Digital', 'Integrasi layanan, data pasien, dan edukasi tenaga kesehatan.'],
]

const INITIAL_FORMS: Record<ResourceKey, Record<string, string>> = {
  patients: { name: '', age: '', gender: '', address: '' },
  doctors: { name: '', specialization: '' },
  appointments: { patient_id: '', doctor_id: '', date: '', notes: '' },
  medicalRecords: { patient_id: '', diagnosis: '' },
}

function getItemId(item: ResourceItem): number | string {
  if ('appointment_id' in item && item.appointment_id) return item.appointment_id
  return 'id' in item && item.id ? item.id : '-'
}

function formatDate(value?: string): string {
  if (!value) return '-'
  const date = new Date(value)
  if (Number.isNaN(date.getTime())) return value
  return new Intl.DateTimeFormat('id-ID', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  }).format(date)
}

function renderCell(resource: ResourceKey, item: ResourceItem): Array<string | number> {
  if (resource === 'patients') {
    const patient = item as Patient
    return [patient.name, patient.age ?? '-', patient.gender ?? '-', patient.address ?? '-']
  }

  if (resource === 'doctors') {
    const doctor = item as Doctor
    return [doctor.name, doctor.specialization ?? '-']
  }

  if (resource === 'appointments') {
    const appointment = item as Appointment
    const timeslot = typeof appointment.timeslot === 'object' && appointment.timeslot
      ? `${appointment.timeslot.day ?? ''} ${appointment.timeslot.start_time ?? ''}-${appointment.timeslot.end_time ?? ''}`.trim()
      : appointment.timeslot ?? '-'
    return [
      appointment.patient_name ?? `Pasien #${appointment.patient_id ?? '-'}`,
      appointment.doctor_name ?? `Dokter #${appointment.doctor_id ?? '-'}`,
      formatDate(appointment.date),
      appointment.room_name ?? '-',
      timeslot || '-',
    ]
  }

  const record = item as MedicalRecord
  return [
    record.patient_name ?? `Pasien #${record.patient_id ?? '-'}`,
    record.diagnosis ?? '-',
    formatDate(record.created_at),
  ]
}

function getHeaders(resource: ResourceKey): string[] {
  return {
    patients: ['Nama', 'Usia', 'Gender', 'Alamat'],
    doctors: ['Nama', 'Spesialisasi'],
    appointments: ['Pasien', 'Dokter', 'Tanggal', 'Ruang', 'Timeslot'],
    medicalRecords: ['Pasien', 'Diagnosis', 'Tanggal'],
  }[resource]
}

function buildPayload(resource: ResourceKey, values: Record<string, string>): CreatePayload {
  if (resource === 'patients') {
    return [{
      name: values.name,
      age: Number(values.age),
      gender: values.gender,
      address: values.address,
    }]
  }

  if (resource === 'doctors') {
    return {
      name: values.name,
      specialization: values.specialization,
    }
  }

  if (resource === 'appointments') {
    return {
      patient_id: Number(values.patient_id),
      doctor_id: Number(values.doctor_id),
      date: values.date,
      notes: values.notes,
    }
  }

  return [{
    patient_id: Number(values.patient_id),
    diagnosis: values.diagnosis,
  }]
}

function itemMatchesSearch(resource: ResourceKey, item: ResourceItem, query: string): boolean {
  if (!query.trim()) return true
  return [getItemId(item), ...renderCell(resource, item)]
    .join(' ')
    .toLowerCase()
    .includes(query.toLowerCase())
}

function SkeletonRows() {
  return (
    <div className="table-skeleton" aria-label="Memuat data">
      {Array.from({ length: 5 }).map((_, index) => (
        <div className="skeleton-row" key={index}>
          <span />
          <span />
          <span />
          <span />
        </div>
      ))}
    </div>
  )
}

function DataTable({
  items,
  onDelete,
  resource,
}: {
  items: ResourceItem[]
  onDelete: (id: number | string) => void
  resource: ResourceKey
}) {
  const headers = getHeaders(resource)

  return (
    <div className="table-wrap">
      <table>
        <thead>
          <tr>
            <th>ID</th>
            {headers.map((header) => (
              <th key={header}>{header}</th>
            ))}
            <th>Aksi</th>
          </tr>
        </thead>
        <tbody>
          {items.map((item) => {
            const id = getItemId(item)
            return (
              <tr key={`${resource}-${id}`}>
                <td className="id-cell">#{id}</td>
                {renderCell(resource, item).map((value, index) => (
                  <td key={`${id}-${index}`}>{value}</td>
                ))}
                <td>
                  <button className="table-action" onClick={() => onDelete(id)} type="button">
                    Hapus
                  </button>
                </td>
              </tr>
            )
          })}
        </tbody>
      </table>
    </div>
  )
}

function HeroVisual() {
  return (
    <div className="hero-visual" aria-hidden="true">
      <div className="hero-card appointment-card">
        <span>Perlu Konsultasi?</span>
        <strong>Jadwalkan Sekarang</strong>
        <small>Mudah, cepat, dan nyaman.</small>
      </div>
      <div className="hero-card doctor-card">
        <span>Dokter tersedia</span>
        <strong>200+</strong>
        <small>Spesialis multidisiplin</small>
      </div>
      <div className="pulse-line" />
    </div>
  )
}

function ResourceForm({
  resource,
  onCreated,
}: {
  resource: ResourceKey
  onCreated: () => void
}) {
  const [values, setValues] = useState(INITIAL_FORMS[resource])
  const [status, setStatus] = useState<'idle' | 'saving' | 'success' | 'error'>('idle')
  const [message, setMessage] = useState('')

  useEffect(() => {
    setValues(INITIAL_FORMS[resource])
    setStatus('idle')
    setMessage('')
  }, [resource])

  const fields = useMemo(() => {
    if (resource === 'patients') {
      return [
        ['name', 'Nama pasien', 'text'],
        ['age', 'Usia', 'number'],
        ['gender', 'Gender', 'text'],
        ['address', 'Alamat', 'text'],
      ]
    }
    if (resource === 'doctors') {
      return [
        ['name', 'Nama dokter', 'text'],
        ['specialization', 'Spesialisasi', 'text'],
      ]
    }
    if (resource === 'appointments') {
      return [
        ['patient_id', 'ID Pasien', 'number'],
        ['doctor_id', 'ID Dokter', 'number'],
        ['date', 'Tanggal appointment', 'datetime-local'],
        ['notes', 'Catatan', 'text'],
      ]
    }
    return [
      ['patient_id', 'ID Pasien', 'number'],
      ['diagnosis', 'Diagnosis', 'text'],
    ]
  }, [resource])

  function updateField(name: string, value: string) {
    setValues((current) => ({ ...current, [name]: value }))
  }

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setStatus('saving')
    setMessage('')

    try {
      await apiCreate(resource, buildPayload(resource, values))
      setValues(INITIAL_FORMS[resource])
      setStatus('success')
      setMessage('Data berhasil disimpan dan daftar diperbarui.')
      onCreated()
    } catch (createError) {
      setStatus('error')
      setMessage(createError instanceof Error ? createError.message : 'Gagal menyimpan data')
    }
  }

  return (
    <form className="resource-form" onSubmit={submit}>
      <div>
        <p className="eyebrow">Input Operasional</p>
        <h3>Tambah {ENDPOINTS[resource].label}</h3>
      </div>

      <div className="form-grid">
        {fields.map(([name, label, type]) => (
          <label key={name}>
            <span>{label}</span>
            <input
              min={type === 'number' ? 1 : undefined}
              onChange={(event) => updateField(name, event.target.value)}
              required={name !== 'notes'}
              type={type}
              value={values[name] ?? ''}
            />
          </label>
        ))}
      </div>

      <div className="form-actions">
        <button className="primary-button" disabled={status === 'saving'} type="submit">
          {status === 'saving' ? 'Menyimpan...' : 'Simpan Data'}
        </button>
        {message && <span className={`form-message ${status}`}>{message}</span>}
      </div>
    </form>
  )
}

function App() {
  const [page, setPage] = useState<PageKey>('home')
  const [activeResource, setActiveResource] = useState<ResourceKey>('patients')
  const [search, setSearch] = useState('')
  const [tableMessage, setTableMessage] = useState('')

  const patients = useResource<Patient>('patients')
  const doctors = useResource<Doctor>('doctors')
  const appointments = useResource<Appointment>('appointments')
  const medicalRecords = useResource<MedicalRecord>('medicalRecords')

  const resourceState = {
    patients,
    doctors,
    appointments,
    medicalRecords,
  }[activeResource]

  const totalAll = patients.data.length + doctors.data.length + appointments.data.length + medicalRecords.data.length

  function reloadAll() {
    patients.reload()
    doctors.reload()
    appointments.reload()
    medicalRecords.reload()
  }

  async function deleteItem(resource: ResourceKey, id: number | string) {
    setTableMessage('')
    try {
      await apiDelete(resource, id)
      setTableMessage(`Data #${id} berhasil dihapus.`)
      const resourceStates = {
        patients,
        doctors,
        appointments,
        medicalRecords,
      }
      resourceStates[resource].reload()
    } catch (deleteError) {
      setTableMessage(deleteError instanceof Error ? deleteError.message : 'Gagal menghapus data')
    }
  }

  function openOperations(resource: ResourceKey) {
    setActiveResource(resource)
    setPage('operations')
    setSearch('')
  }

  return (
    <main className="app-shell">
      <header className="top-contact">
        <div>
          <button type="button">Pasien & Pengunjung</button>
          <button type="button">Profil Rumah Sakit</button>
        </div>
        <div>
          <span>Hubungi Kami: 0811 9113 913</span>
          <strong>Emergency</strong>
        </div>
      </header>

      <nav className="main-nav" aria-label="Navigasi utama">
        <button className="brand-block brand-button" onClick={() => setPage('home')} type="button">
          <span className="brand-mark">RS</span>
          <span>
            <strong>Impilo Hospital</strong>
            <small>Smart hospital information system</small>
          </span>
        </button>

        <div className="nav-links">
          {[
            ['home', 'Beranda'],
            ['doctors', 'Cari Dokter'],
            ['services', 'Layanan Kesehatan'],
            ['news', 'Info & Media'],
            ['operations', 'Admin RS'],
          ].map(([key, label]) => (
            <button
              className={page === key ? 'nav-link active' : 'nav-link'}
              key={key}
              onClick={() => setPage(key as PageKey)}
              type="button"
            >
              {label}
            </button>
          ))}
        </div>

        <button className="primary-button" onClick={() => openOperations('appointments')} type="button">
          Buat Janji
        </button>
      </nav>

      {page === 'home' && (
        <>
          <section className="hero-section">
            <div className="hero-copy">
              <p className="eyebrow">Rumah Sakit Digital Terintegrasi</p>
              <h1>Perlu Konsultasi? Jadwalkan Sekarang!</h1>
              <p className="hero-text">
                Web rumah sakit untuk pasien dan staff: cari dokter, lihat layanan, buat janji,
                registrasi pasien, dan kelola rekam medis dalam satu sistem.
              </p>
              <div className="hero-actions">
                <button className="primary-button" onClick={() => openOperations('appointments')} type="button">
                  Buat Janji
                </button>
                <button className="secondary-button" onClick={() => setPage('doctors')} type="button">
                  Cari Dokter
                </button>
              </div>
            </div>
            <HeroVisual />
          </section>

          <section className="quick-search-card">
            <button onClick={() => setPage('doctors')} type="button">
              <span>Cari:</span>
              <strong>Dokter</strong>
              <small>Temukan dokter dan spesialisasi</small>
            </button>
            <button onClick={() => setPage('services')} type="button">
              <span>Cari:</span>
              <strong>Klinik & Layanan</strong>
              <small>Lihat fasilitas rumah sakit</small>
            </button>
          </section>

          <section className="about-section">
            <div>
              <p className="eyebrow">Tentang Rumah Sakit</p>
              <h2>Pelayanan berbasis data untuk pasien, dokter, dan operasional.</h2>
              <p>
                Impilo Hospital menghubungkan layanan publik rumah sakit dengan sistem internal:
                appointment, data dokter, registrasi pasien, dan rekam medis berjalan melalui API Gateway.
              </p>
            </div>
            <div className="stats-row">
              <div><strong>{doctors.data.length || '200+'}</strong><span>Spesialis</span></div>
              <div><strong>300+</strong><span>Jumlah Kasur</span></div>
              <div><strong>{patients.data.length}</strong><span>Pasien Terdaftar</span></div>
              <div><strong>{totalAll}</strong><span>Data Aktif</span></div>
            </div>
          </section>

          <section className="content-section">
            <div className="section-title">
              <p className="eyebrow">Center of Excellence</p>
              <h2>Layanan unggulan rumah sakit</h2>
            </div>
            <div className="card-grid three">
              {EXCELLENCE_CARDS.map(([title, body]) => (
                <article className="info-card" key={title}>
                  <span />
                  <h3>{title}</h3>
                  <p>{body}</p>
                </article>
              ))}
            </div>
          </section>
        </>
      )}

      {page === 'doctors' && (
        <section className="content-section page-block">
          <div className="section-title split">
            <div>
              <p className="eyebrow">Cari Dokter</p>
              <h2>Temukan dokter berdasarkan data service.</h2>
            </div>
            <button className="secondary-button" onClick={() => openOperations('doctors')} type="button">
              Kelola Dokter
            </button>
          </div>
          <DataModule
            activeResource="doctors"
            data={doctors.data}
            error={doctors.error}
            loading={doctors.loading}
            onDelete={(id) => {
              setActiveResource('doctors')
              void deleteItem('doctors', id)
            }}
            onReload={doctors.reload}
            search={search}
            setSearch={setSearch}
          />
        </section>
      )}

      {page === 'services' && (
        <section className="content-section page-block">
          <div className="section-title">
            <p className="eyebrow">Fasilitas dan Layanan</p>
            <h2>Layanan kesehatan untuk kebutuhan pasien.</h2>
          </div>
          <div className="card-grid services">
            {FEATURED_SERVICES.map(([title, body]) => (
              <article className="service-card" key={title}>
                <span />
                <h3>{title}</h3>
                <p>{body}</p>
              </article>
            ))}
          </div>
        </section>
      )}

      {page === 'news' && (
        <section className="content-section page-block">
          <div className="section-title split">
            <div>
              <p className="eyebrow">Info & Media</p>
              <h2>Promo dan berita rumah sakit.</h2>
            </div>
            <button className="secondary-button" onClick={reloadAll} type="button">Refresh Data</button>
          </div>
          <div className="card-grid three">
            {NEWS_ITEMS.map(([title, body]) => (
              <article className="news-card" key={title}>
                <small>2026</small>
                <h3>{title}</h3>
                <p>{body}</p>
              </article>
            ))}
          </div>
        </section>
      )}

      {page === 'operations' && (
        <section className="content-section page-block">
          <div className="section-title split">
            <div>
              <p className="eyebrow">Admin Rumah Sakit</p>
              <h2>Kelola data operasional</h2>
            </div>
            <span className="api-chip">{CONFIG.apiBaseUrl}</span>
          </div>

          <section className="module-tabs" aria-label="Pilih modul data">
            {RESOURCE_ITEMS.map((item) => (
              <button
                className={item.key === activeResource ? 'module-card active' : 'module-card'}
                key={item.key}
                onClick={() => openOperations(item.key)}
                type="button"
              >
                <span>{item.description}</span>
                <strong>{item.label}</strong>
                <small>{{
                  patients: patients.data.length,
                  doctors: doctors.data.length,
                  appointments: appointments.data.length,
                  medicalRecords: medicalRecords.data.length,
                }[item.key]} data</small>
              </button>
            ))}
          </section>

          <div className="operations-layout">
            <ResourceForm resource={activeResource} onCreated={resourceState.reload} />

            <DataModule
              activeResource={activeResource}
              data={resourceState.data}
              error={resourceState.error}
              loading={resourceState.loading}
              message={tableMessage}
              onDelete={(id) => void deleteItem(activeResource, id)}
              onReload={resourceState.reload}
              search={search}
              setSearch={setSearch}
            />
          </div>
        </section>
      )}

      <footer className="site-footer">
        <div>
          <strong>Impilo Hospital</strong>
          <span>Smart hospital system untuk demo microservices.</span>
        </div>
        <span>API Gateway: {CONFIG.apiBaseUrl}</span>
      </footer>
    </main>
  )
}

function DataModule({
  activeResource,
  data,
  error,
  loading,
  message,
  onDelete,
  onReload,
  search,
  setSearch,
}: {
  activeResource: ResourceKey
  data: ResourceItem[]
  error: string | null
  loading: boolean
  message?: string
  onDelete: (id: number | string) => void
  onReload: () => void
  search: string
  setSearch: (value: string) => void
}) {
  const filteredData = data.filter((item) => itemMatchesSearch(activeResource, item, search))
  const endpoint = ENDPOINTS[activeResource]

  return (
    <section className="data-panel">
      <div className="panel-header">
        <div>
          <h2>{endpoint.label}</h2>
          <p>{endpoint.path}</p>
        </div>
        <button className="secondary-button compact" onClick={onReload} type="button">Refresh</button>
      </div>

      <div className="table-tools">
        <input
          aria-label="Cari data"
          onChange={(event) => setSearch(event.target.value)}
          placeholder={`Cari ${endpoint.label.toLowerCase()}...`}
          type="search"
          value={search}
        />
        <span>{loading ? 'Memuat' : `${filteredData.length} dari ${data.length} data`}</span>
      </div>

      {message && <div className="inline-message">{message}</div>}
      {loading && <SkeletonRows />}

      {!loading && error && (
        <div className="state-box error">
          <strong>Data belum bisa dimuat</strong>
          <span>{error}</span>
          <button onClick={onReload} type="button">Coba lagi</button>
        </div>
      )}

      {!loading && !error && filteredData.length === 0 && (
        <div className="state-box">
          <strong>Belum ada data</strong>
          <span>Endpoint aktif, tetapi data belum tersedia atau tidak cocok dengan pencarian.</span>
        </div>
      )}

      {!loading && !error && filteredData.length > 0 && (
        <DataTable items={filteredData} onDelete={onDelete} resource={activeResource} />
      )}
    </section>
  )
}

export default App
