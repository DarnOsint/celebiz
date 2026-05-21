import { useState, useEffect } from 'react'
import { supabase } from '../../lib/supabase'
import { setActiveCurrency, invalidateCurrencyCache } from '../../lib/currency'

export default function CurrencySelector() {
  const [currency, setCurrency] = useState<'SSP' | 'USD'>('SSP')
  const [toggling, setToggling] = useState(false)

  useEffect(() => {
    supabase
      .from('settings')
      .select('value')
      .eq('id', 'active_currency')
      .maybeSingle()
      .then(({ data }) => {
        if (data?.value === 'USD') setCurrency('USD')
      })
  }, [])

  const toggle = async (code: 'SSP' | 'USD') => {
    setToggling(true)
    await setActiveCurrency(code)
    setCurrency(code)
    setToggling(false)
  }

  return (
    <div className="bg-gray-900 border border-gray-800 rounded-2xl p-4 md:p-5 mb-8">
      <h3 className="text-white font-semibold text-sm md:text-base mb-4">Currency</h3>
      <div className="flex gap-3">
        <button
          onClick={() => toggle('SSP')}
          disabled={toggling}
          className={`flex-1 py-2.5 px-3 rounded-xl border text-sm font-medium transition-colors ${
            currency === 'SSP'
              ? 'bg-amber-500/20 border-amber-500 text-amber-400'
              : 'bg-gray-800 border-gray-700 text-gray-400 hover:text-white'
          }`}
        >
          SSP
        </button>
        <button
          onClick={() => toggle('USD')}
          disabled={toggling}
          className={`flex-1 py-2.5 px-3 rounded-xl border text-sm font-medium transition-colors ${
            currency === 'USD'
              ? 'bg-amber-500/20 border-amber-500 text-amber-400'
              : 'bg-gray-800 border-gray-700 text-gray-400 hover:text-white'
          }`}
        >
          $ USD
        </button>
      </div>
    </div>
  )
}
