import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

if (!supabaseUrl) {
  throw new Error('VITE_SUPABASE_URL is not set in environment')
}
if (!supabaseAnonKey) {
  throw new Error('VITE_SUPABASE_ANON_KEY is not set in environment')
}

// Primary client used by the app
export const supabase = createClient(supabaseUrl, supabaseAnonKey)
// Secondary client used only for audit writes (used by audit helper)
export const auditClient = createClient(supabaseUrl, supabaseAnonKey)
