import { render, screen, waitFor } from '@testing-library/react'
import { afterEach, describe, expect, it, vi } from 'vitest'
import App from './App'

function jsonResponse(payload: unknown, init?: ResponseInit): Response {
  return new Response(JSON.stringify(payload), {
    headers: { 'Content-Type': 'application/json' },
    status: init?.status ?? 200,
    ...init,
  })
}

afterEach(() => {
  vi.unstubAllGlobals()
})

describe('App', () => {
  it('shows loading state while fetching data', () => {
    vi.stubGlobal('fetch', vi.fn(() => new Promise(() => undefined)))

    render(<App />)

    expect(screen.getByLabelText('Memuat data')).toBeInTheDocument()
  })

  it('renders patient data from the API gateway', async () => {
    vi.stubGlobal('fetch', vi.fn().mockResolvedValue(jsonResponse({
      success: true,
      patients: [
        {
          id: 1,
          name: 'Andi Wijaya',
          age: 30,
          gender: 'Laki-laki',
          address: 'Kendari',
        },
      ],
    })))

    render(<App />)

    expect(await screen.findByText('Andi Wijaya')).toBeInTheDocument()
    expect(screen.getByText('Kendari')).toBeInTheDocument()
    expect(fetch).toHaveBeenCalledWith(
      'http://localhost/api/patients',
      expect.objectContaining({
        headers: { Accept: 'application/json' },
      }),
    )
  })

  it('renders error state when the API fails', async () => {
    vi.stubGlobal('fetch', vi.fn().mockResolvedValue(jsonResponse(
      { error: 'Gateway tidak tersedia' },
      { status: 500 },
    )))

    render(<App />)

    await waitFor(() => {
      expect(screen.getByText('Data belum bisa dimuat')).toBeInTheDocument()
    })
    expect(screen.getByText('Pasien: Gateway tidak tersedia')).toBeInTheDocument()
  })
})
