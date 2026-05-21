-- Revert RLS hardening — the app uses anon key for all queries
-- (PIN login does not create a Supabase Auth session),
-- so auth.role() is always 'anon'. RLS cannot enforce per-user
-- restrictions without proper Supabase Auth sessions.

-- Drop all role-based policies added by rls_hardening.sql
drop policy if exists "orders_read_own_or_manager" on public.orders;
drop policy if exists "orders_insert_authenticated" on public.orders;
drop policy if exists "orders_update_own_or_manager" on public.orders;
drop policy if exists "orders_delete_own_or_manager" on public.orders;

drop policy if exists "order_items_read" on public.order_items;
drop policy if exists "order_items_insert" on public.order_items;
drop policy if exists "order_items_update" on public.order_items;
drop policy if exists "order_items_delete" on public.order_items;

drop policy if exists "profiles_insert_own" on public.profiles;
drop policy if exists "profiles_read_authenticated" on public.profiles;
drop policy if exists "profiles_update_own_or_manager" on public.profiles;
drop policy if exists "profiles_delete_manager_only" on public.profiles;

drop policy if exists "payouts_select_own_or_manager" on public.payouts;
drop policy if exists "payouts_insert_own" on public.payouts;
drop policy if exists "payouts_update_own_or_manager" on public.payouts;

drop policy if exists "attendance_select_own_or_manager" on public.attendance;
drop policy if exists "attendance_insert_own" on public.attendance;
drop policy if exists "attendance_update_own_or_manager" on public.attendance;

drop policy if exists "game_sales_read_write_authenticated" on public.game_sales;
drop policy if exists "shisha_sales_read_write_authenticated" on public.shisha_sales;
drop policy if exists "game_types_read_authenticated" on public.game_types;
drop policy if exists "game_types_write_owner_manager" on public.game_types;
drop policy if exists "game_types_update_owner_manager" on public.game_types;
drop policy if exists "game_types_delete_owner_manager" on public.game_types;

drop policy if exists "debtors_update_own_or_manager" on public.debtors;

-- Restore original wide policies

-- PROFILES — all authenticated users can read any profile;
-- users insert own, update any, delete own
create policy "profiles_read"
  on public.profiles for select
  using (true);

create policy "profiles_insert"
  on public.profiles for insert
  with check (auth.role() = 'authenticated');

create policy "profiles_update"
  on public.profiles for update
  using (true)
  with check (true);

create policy "profiles_delete"
  on public.profiles for delete
  using (auth.role() = 'authenticated');

-- ORDERS — access controlled by RPC / app layer only
create policy "orders_all"
  on public.orders for all
  using (true)
  with check (true);

create policy "orders_read_all"
  on public.orders for select
  using (auth.role() = 'authenticated');

create policy "orders_insert_all"
  on public.orders for insert
  with check (auth.role() = 'authenticated');

create policy "orders_update_all"
  on public.orders for update
  using (auth.role() = 'authenticated');

-- ORDER ITEMS — access controlled by RPC / app layer only
create policy "order_items_all"
  on public.order_items for all
  using (true)
  with check (true);

create policy "order_items_insert"
  on public.order_items for insert
  with check (auth.role() = 'authenticated');

create policy "order_items_read"
  on public.order_items for select
  using (auth.role() = 'authenticated');

create policy "order_items_update"
  on public.order_items for update
  using (auth.role() = 'authenticated');

-- PAYOUTS
create policy "payouts_all"
  on public.payouts for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

create policy "payouts_read"
  on public.payouts for select
  using (auth.role() = 'authenticated');

-- ATTENDANCE
create policy "attendance_read"
  on public.attendance for select
  using (auth.role() = 'authenticated');

create policy "attendance_insert"
  on public.attendance for insert
  with check (auth.role() = 'authenticated');

create policy "attendance_update"
  on public.attendance for update
  using (auth.role() = 'authenticated');

-- GAME TYPES — wide open for authenticated
create policy "game_types_all"
  on public.game_types for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

-- GAME SALES — wide open for authenticated
create policy "game_sales_all"
  on public.game_sales for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

-- SHISHA SALES — wide open for authenticated
create policy "shisha_sales_all"
  on public.shisha_sales for all
  using (auth.role() = 'authenticated')
  with check (auth.role() = 'authenticated');

-- DEBTORS
create policy "debtors_update"
  on public.debtors for update
  using (auth.role() = 'authenticated');

drop function if exists public.get_user_role;
