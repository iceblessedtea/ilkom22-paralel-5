import { CONFIG } from '../config'

export type ResourceKey = 'patients' | 'doctors' | 'appointments' | 'medicalRecords'

type JsonValue = unknown

export interface Patient {
  id: number
  name: string
  age?: number
  gender?: string
  address?: string
}

export interface Doctor {
  id: number
  name: string
  specialization?: string
}

export interface Appointment {
  id?: number
  appointment_id?: number
  patient_id?: number
  patient_name?: string
  doctor_id?: number
  doctor_name?: string
  date?: string
  notes?: string
  room_name?: string
  timeslot?: string | {
    day?: string
    start_time?: string
    end_time?: string
  }
}

export interface MedicalRecord {
  id: number
  patient_id?: number
  patient_name?: string
  diagnosis?: string
  created_at?: string
  updated_at?: string
}

export interface ResourceConfig<T> {
  label: string
  path: string
  normalize: (payload: JsonValue) => T[]
}

function asArray<T>(payload: JsonValue): T[] {
  return Array.isArray(payload) ? payload as T[] : []
}

export const ENDPOINTS: Record<ResourceKey, ResourceConfig<Patient | Doctor | Appointment | MedicalRecord>> = {
  patients: {
    label: 'Pasien',
    path: '/api/patients',
    normalize: (payload) => {
      if (payload && typeof payload === 'object' && 'patients' in payload) {
        return asArray<Patient>((payload as { patients: JsonValue }).patients)
      }
      return asArray<Patient>(payload)
    },
  },
  doctors: {
    label: 'Dokter',
    path: '/api/doctors',
    normalize: (payload) => asArray<Doctor>(payload),
  },
  appointments: {
    label: 'Janji Temu',
    path: '/api/appointments',
    normalize: (payload) => asArray<Appointment>(payload),
  },
  medicalRecords: {
    label: 'Rekam Medis',
    path: '/api/medical-records',
    normalize: (payload) => asArray<MedicalRecord>(payload),
  },
}

export async function apiGet<T extends Patient | Doctor | Appointment | MedicalRecord>(
  resource: ResourceKey,
  signal?: AbortSignal,
): Promise<T[]> {
  const endpoint = ENDPOINTS[resource]
  const response = await fetch(`${CONFIG.apiBaseUrl}${endpoint.path}`, {
    headers: { Accept: 'application/json' },
    signal,
  })

  if (response.status === 404) {
    return []
  }

  const payload = await response.json().catch(() => null)

  if (!response.ok) {
    const errorMessage = payload && typeof payload === 'object' && 'error' in payload
      ? String((payload as { error: unknown }).error)
      : `HTTP ${response.status}`
    throw new Error(`${endpoint.label}: ${errorMessage}`)
  }

  return endpoint.normalize(payload) as T[]
}
