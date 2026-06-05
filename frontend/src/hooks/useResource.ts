import { useCallback, useEffect, useState } from 'react'
import { apiGet, type Appointment, type Doctor, type MedicalRecord, type Patient, type ResourceKey } from '../services/api'

export type ResourceItem = Patient | Doctor | Appointment | MedicalRecord

interface ResourceState<T> {
  data: T[]
  error: string | null
  loading: boolean
  reload: () => void
}

export function useResource<T extends ResourceItem>(resource: ResourceKey): ResourceState<T> {
  const [data, setData] = useState<T[]>([])
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(true)
  const [version, setVersion] = useState(0)

  const reload = useCallback(() => {
    setVersion((current) => current + 1)
  }, [])

  useEffect(() => {
    const controller = new AbortController()

    setLoading(true)
    setError(null)

    apiGet<T>(resource, controller.signal)
      .then((items) => {
        setData(items)
      })
      .catch((fetchError: unknown) => {
        if (fetchError instanceof DOMException && fetchError.name === 'AbortError') {
          return
        }
        setError(fetchError instanceof Error ? fetchError.message : 'Gagal mengambil data')
        setData([])
      })
      .finally(() => {
        if (!controller.signal.aborted) {
          setLoading(false)
        }
      })

    return () => controller.abort()
  }, [resource, version])

  return { data, error, loading, reload }
}
