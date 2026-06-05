import { useMemo, useState } from 'react'
import './App.css'
import { CONFIG } from './config'
import { useResource, type ResourceItem } from './hooks/useResource'
import { ENDPOINTS, type Appointment, type Doctor, type MedicalRecord, type Patient, type ResourceKey } from './services/api'

const NAV_ITEMS: Array<{ key: ResourceKey; label: string; tone: string }> = [
  { key: 'patients', label: 'Pasien', tone: 'green' },
  { key: 'doctors', label: 'Dokter', tone: 'blue' },
  { key: 'appointments', label: 'Janji Temu', tone: 'orange' },
  { key: 'medicalRecords', label: 'Rekam Medis', tone: 'red' },
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

function App() {
  const [activeResource, setActiveResource] = useState<ResourceKey>('patients')
  const { data, error, loading, reload } = useResource<ResourceItem>(activeResource)

  const activeEndpoint = ENDPOINTS[activeResource]
  const totalCount = data.length

  const statItems = useMemo(
    () => NAV_ITEMS.map((item) => ({
      ...item,
      active: item.key === activeResource,
    })),
    [activeResource],
  )

  return (
    <main className="app-shell">
      <aside className="sidebar" aria-label="Navigasi data">
        <div className="brand-block">
          <span className="brand-mark">H</span>
          <div>
            <strong>Healthcare OS</strong>
            <small>Microservice Console</small>
          </div>
        </div>

        <nav className="nav-stack">
          {NAV_ITEMS.map((item) => (
            <button
              className={item.key === activeResource ? 'nav-item active' : 'nav-item'}
              key={item.key}
              onClick={() => setActiveResource(item.key)}
              type="button"
            >
              <span className={`nav-dot ${item.tone}`} />
              {item.label}
            </button>
          ))}
        </nav>

        <div className="gateway-status">
          <span>API Base</span>
          <strong>{CONFIG.apiBaseUrl}</strong>
        </div>
      </aside>

      <section className="workspace">
        <header className="topbar">
          <div>
            <p className="eyebrow">Phase 4 Integration</p>
            <h1>{activeEndpoint.label}</h1>
          </div>
          <button className="refresh-button" onClick={reload} type="button">
            Refresh
          </button>
        </header>

        <section className="stats-grid" aria-label="Ringkasan resource">
          {statItems.map((item) => (
            <button
              className={item.active ? `stat-card active ${item.tone}` : `stat-card ${item.tone}`}
              key={item.key}
              onClick={() => setActiveResource(item.key)}
              type="button"
            >
              <span>{item.label}</span>
              <strong>{item.active ? totalCount : '-'}</strong>
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
    </main>
  )
}

export default App
