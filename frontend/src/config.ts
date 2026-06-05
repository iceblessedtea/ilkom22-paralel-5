export const CONFIG = {
  apiBaseUrl: (import.meta.env.VITE_API_BASE_URL || 'http://localhost').replace(/\/$/, ''),
}
