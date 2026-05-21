import { supabase } from './supabase'

type CurrencyCode = 'SSP' | 'USD'

let _code: CurrencyCode = 'SSP'
let _rate = 2200
let _loaded = false

const SYMBOLS: Record<CurrencyCode, string> = {
  SSP: 'SSP',
  USD: '$',
}

export function getCurrencySymbol(): string {
  return SYMBOLS[_code]
}

export function getCurrencyCode(): CurrencyCode {
  return _code
}

export function getExchangeRate(): number {
  return _rate
}

let loadingPromise: Promise<void> | null = null

export async function initCurrency(): Promise<void> {
  if (_loaded) return
  if (loadingPromise) return loadingPromise
  loadingPromise = (async () => {
    try {
      const { data } = await supabase
        .from('settings')
        .select('id, value')
        .in('id', ['active_currency', 'exchange_rate'])
      if (!data) return
      const map = Object.fromEntries(
        data.map((r: { id: string; value: string | number }) => [r.id, r.value])
      )
      if (map['active_currency'] === 'USD' || map['active_currency'] === '"USD"') _code = 'USD'
      const rawRate = String(map['exchange_rate'] || '2200').replace(/"/g, '')
      _rate = parseFloat(rawRate) || 2200
    } catch {
      // keep defaults
    }
    _loaded = true
  })()
  return loadingPromise
}

export function invalidateCurrencyCache() {
  _loaded = false
  loadingPromise = null
}

export function formatPrice(amount: number): string {
  const formatted = Number(amount || 0).toLocaleString('en-US', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  })
  return `${SYMBOLS[_code]}${formatted}`
}

export async function setActiveCurrency(code: CurrencyCode): Promise<void> {
  await supabase.from('settings').upsert(
    {
      id: 'active_currency',
      value: code,
      updated_at: new Date().toISOString(),
    },
    { onConflict: 'id' }
  )
  _code = code
}

export async function setExchangeRate(rate: number): Promise<void> {
  await supabase.from('settings').upsert(
    {
      id: 'exchange_rate',
      value: String(rate),
      updated_at: new Date().toISOString(),
    },
    { onConflict: 'id' }
  )
  _rate = rate
}
