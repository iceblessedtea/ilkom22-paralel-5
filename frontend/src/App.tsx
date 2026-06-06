import { useState } from 'react'
import './App.css'
import { CONFIG } from './config'
import { useResource, type ResourceItem } from './hooks/useResource'
import { ENDPOINTS, type Appointment, type Doctor, type MedicalRecord, type Patient, type ResourceKey } from './services/api'

const NAV_ITEMS: Array<{ key: ResourceKey; label: string; description: string }> = [
  { key: 'patients', label: 'Pasien', description: 'Identity graph' },
  { key: 'doctors', label: 'Dokter', description: 'Care team' },
  { key: 'appointments', label: 'Janji Temu', description: 'Scheduling' },
  { key: 'medicalRecords', label: 'Rekam Medis', description: 'Clinical notes' },
]

function getItemId(item: ResourceItem): number | string {
  if ('appointment_id' in item && item.appointment_id) {
    return item.appointment_id
  }
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
  const headers: Record<ResourceKey, string[]> = {
    patients: ['Nama', 'Usia', 'Gender', 'Alamat'],
    doctors: ['Nama', 'Spesialisasi'],
    appointments: ['Pasien', 'Dokter', 'Tanggal', 'Ruang', 'Timeslot'],
    medicalRecords: ['Pasien', 'Diagnosis', 'Tanggal'],
  }
  return headers[resource]
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

function DataTable({ items, resource }: { items: ResourceItem[]; resource: ResourceKey }) {
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
          </tr>
        </thead>
        <tbody>
          {items.map((item) => (
            <tr key={`${resource}-${getItemId(item)}`}>
              <td className="id-cell">#{getItemId(item)}</td>
              {renderCell(resource, item).map((value, index) => (
                <td key={`${getItemId(item)}-${index}`}>{value}</td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}

function LineArtIllustration() {
  return (
    <div className="line-art" aria-hidden="true">
      <svg viewBox="0 0 320 420" role="img">
        <path d="M64 64h128a26 26 0 0 1 26 26v92a26 26 0 0 1-26 26H64a26 26 0 0 1-26-26V90a26 26 0 0 1 26-26Z" />
        <path d="M76 114h48l18-28 30 78 18-50h40" />
        <path d="M82 242c0 62 35 98 78 98s78-36 78-98" />
        <path d="M82 242v-38M238 242v-38" />
        <path d="M108 362h104M132 386h56" />
        <circle cx="70" cy="204" r="15" />
        <circle cx="250" cy="204" r="15" />
        <path d="M246 72h32a18 18 0 0 1 18 18v168a18 18 0 0 1-18 18h-32" />
        <path d="M262 112h16M262 142h16M262 172h16" />
      </svg>
    </div>
  )
}

function DashboardPreview({
  activeEndpoint,
  activeResource,
  totalCount,
}: {
  activeEndpoint: typeof ENDPOINTS[ResourceKey]
  activeResource: ResourceKey
  totalCount: number
}) {
  return (
    <article className="dashboard-card" aria-label="Clinical dashboard preview">
      <div className="dashboard-topline">
        <span>Live Resource Monitor</span>
        <span className="status-pill"><i /> Online</span>
      </div>

      <div className="tab-strip">
        {NAV_ITEMS.map((item) => (
          <span className={item.key === activeResource ? 'tab active' : 'tab'} key={item.key}>
            <i />
            {item.label}
          </span>
        ))}
      </div>

      <div className="metric-layout">
        <div className="metric-hero">
          <span>{activeEndpoint.label}</span>
          <strong>{totalCount}</strong>
          <small>{activeEndpoint.path}</small>
        </div>
        <div className="billing-list">
          <div><span /> Patient API <strong>Healthy</strong></div>
          <div><span /> Gateway <strong>Synced</strong></div>
          <div><span /> PostgreSQL <strong>Ready</strong></div>
        </div>
      </div>

      <div className="chart-card">
        <svg viewBox="0 0 560 150" aria-hidden="true">
          <path className="grid" d="M0 30H560M0 75H560M0 120H560" />
          <path className="cyan-line" d="M0 112C44 86 68 92 104 70C148 43 178 44 216 76C254 108 290 102 330 66C374 26 412 42 452 60C498 82 526 64 560 38" />
          <path className="mint-line" d="M0 92C52 76 84 72 124 92C172 116 212 106 252 82C298 54 338 64 374 92C412 120 454 114 496 90C526 74 544 72 560 76" />
        </svg>
      </div>
    </article>
  )
}

function App() {
  const [activeResource, setActiveResource] = useState<ResourceKey>('patients')
  const { data, error, loading, reload } = useResource<ResourceItem>(activeResource)

  const activeEndpoint = ENDPOINTS[activeResource]
  const totalCount = data.length

  return (
    <main className="app-shell">
      <section className="dark-canvas">
        <nav className="nav-bar" aria-label="Navigasi utama">
          <div className="brand-block">
            <span className="brand-mark">I</span>
            <div>
              <strong>Impilo</strong>
              <small>Healthcare observatory</small>
            </div>
          </div>

          <div className="nav-links">
            <a href="#dashboard">Dashboard</a>
            <a href="#records">Records</a>
            <a href="#deployment">Deployment</a>
          </div>

          <button className="pill-button primary" onClick={reload} type="button">
            Request Demo
          </button>
        </nav>

        <section className="hero-section">
          <LineArtIllustration />

          <div className="hero-copy">
            <p className="eyebrow">Healthcare Microservices Console</p>
            <h1>
              Clinical data, engineered to feel
              {' '}
              <span className="word-highlight">personalized.</span>
            </h1>
            <p className="hero-text">
              Pantau pasien, dokter, appointment, dan rekam medis dari satu command console
              dengan aksen data cyan, status vital mint, dan PostgreSQL-backed services.
            </p>
            <div className="hero-actions">
              <button className="pill-button primary" onClick={reload} type="button">
                Refresh Data
              </button>
              <a className="pill-button ghost" href="#records">- Explore Records</a>
            </div>
          </div>
        </section>

        <section className="dashboard-section" id="dashboard">
          <DashboardPreview
            activeEndpoint={activeEndpoint}
            activeResource={activeResource}
            totalCount={totalCount}
          />
        </section>
      </section>

      <section className="workspace" id="records">
        <div className="section-heading">
          <div>
            <p className="eyebrow">Resource Explorer</p>
            <h2>Service data stream</h2>
          </div>
          <span className="api-chip">{CONFIG.apiBaseUrl}</span>
        </div>

        <section className="stats-grid" aria-label="Ringkasan resource">
          {NAV_ITEMS.map((item) => (
            <button
              className={item.key === activeResource ? 'stat-card active' : 'stat-card'}
              key={item.key}
              onClick={() => setActiveResource(item.key)}
              type="button"
            >
              <span>{item.description}</span>
              <strong>{item.label}</strong>
              <small>{item.key === activeResource ? `${totalCount} data` : 'Select feed'}</small>
            </button>
          ))}
        </section>

        <section className="data-panel">
          <div className="panel-header">
            <div>
              <h2>{activeEndpoint.label}</h2>
              <p>{activeEndpoint.path}</p>
            </div>
            <span className="badge">{loading ? 'Memuat' : `${totalCount} data`}</span>
          </div>

          {loading && <SkeletonRows />}

          {!loading && error && (
            <div className="state-box error">
              <strong>Data belum bisa dimuat</strong>
              <span>{error}</span>
              <button onClick={reload} type="button">Coba lagi</button>
            </div>
          )}

          {!loading && !error && data.length === 0 && (
            <div className="state-box">
              <strong>Belum ada data</strong>
              <span>Endpoint aktif, tetapi resource ini belum memiliki isi.</span>
            </div>
          )}

          {!loading && !error && data.length > 0 && (
            <DataTable items={data} resource={activeResource} />
          )}
        </section>
      </section>

      <section className="light-section" id="deployment">
        <div className="light-content">
          <p className="eyebrow">Deployment Ready</p>
          <h2>End-to-end service clarity, from API gateway to restore drill.</h2>
          <p>
            Desain ini mengikuti referensi Impilo: dark violet canvas, cards yang lembut,
            aksen cyan untuk data, mint untuk status sehat, dan hard cut ke section terang.
          </p>
          <div className="badge-pair">
            <div><span>PG</span><strong>PostgreSQL</strong><small>per-service database</small></div>
            <div><span>OT</span><strong>OpenTelemetry</strong><small>trace-ready runtime</small></div>
          </div>
        </div>
      </section>
    </main>
  )
}

export default App
