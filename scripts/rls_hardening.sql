-- RLS Policy Hardening
-- Replaces wide-open policies with role-based checks.
-- Manager/owner roles get full access; other staff see/act on their own data only.

-- Helper function: get the current user's role
create or replace function public.get_user_role()
returns text
language sql
stable
security definer
as $$
  select role from public.profiles where id = auth.uid();
$$;

-- ============================================================
-- ORDERS
-- ============================================================
drop policy if exists "orders_all" on public.orders;
drop policy if exists "orders_read_all" on public.orders;
drop policy if exists "orders_insert_all" on public.orders;
drop policy if exists "orders_update_all" on public.orders;

create policy "orders_read_own_or_manager"
  on public.orders for select
  using (
    auth.role() = 'authenticated'
    and (
      staff_id = auth.uid()
      or public.get_user_role() in ('owner', 'manager', 'supervisor', 'admin')
    )
  );

create policy "orders_insert_authenticated"
  on public.orders for insert
  with check (
    auth.role() = 'authenticated'
    and staff_id = auth.uid()
  );

create policy "orders_update_own_or_manager"
  on public.orders for update
  using (
    auth.role() = 'authenticated'
    and (
      staff_id = auth.uid()
      or public.get_user_role() in ('owner', 'manager', 'supervisor', 'admin')
    )
  );

create policy "orders_delete_own_or_manager"
  on public.orders for delete
  using (
    auth.role() = 'authenticated'
    and (
      staff_id = auth.uid()
      or public.get_user_role() in ('owner', 'manager', 'supervisor', 'admin')
    )
  );

-- ============================================================
-- ORDER ITEMS
-- ============================================================
drop policy if exists "order_items_all" on public.order_items;
drop policy if exists "order_items_insert" on public.order_items;
drop policy if exists "order_items_read" on public.order_items;
drop policy if exists "order_items_update" on public.order_items;

create policy "order_items_read"
  on public.order_items for select
  using (
    auth.role() = 'authenticated'
  );

create policy "order_items_insert"
  on public.order_items for insert
  with check (
    auth.role() = 'authenticated'
  );

create policy "order_items_update"
  on public.order_items for update
  using (
    auth.role() = 'authenticated'
  );

create policy "order_items_delete"
  on public.order_items for delete
  using (
    auth.role() = 'authenticated'
  );

-- ============================================================
-- PROFILES — users update own row only (unless manager)
-- ============================================================
drop policy if exists "profiles_update" on public.profiles;
drop policy if exists "profiles_delete" on public.profiles;
drop policy if exists "profiles_insert_own" on public.profiles;
drop policy if exists "profiles_insert" on public.profiles;

create policy "profiles_insert_own"
  on public.profiles for insert
  with check (
    auth.uid() = id
  );

create policy "profiles_read_authenticated"
  on public.profiles for select
  using (
    auth.role() = 'authenticated'
    and (
      id = auth.uid()
      or public.get_user_role() in ('owner', 'manager', 'supervisor', 'admin')
    )
  );

create policy "profiles_update_own_or_manager"
  on public.profiles for update
  using (
    auth.role() = 'authenticated'
    and (
      id = auth.uid()
      or public.get_user_role() in ('owner', 'manager', 'supervisor', 'admin')
    )
  );

create policy "profiles_delete_manager_only"
  on public.profiles for delete
  using (
    auth.role() = 'authenticated'
    and public.get_user_role() in ('owner', 'manager', 'admin')
  );

-- ============================================================
-- PAYOUTS — staff see own; managers see all
-- ============================================================
drop policy if exists "payouts_all" on public.payouts;
drop policy if exists "payouts_read" on public.payouts;

create policy "payouts_select_own_or_manager"
  on public.payouts for select
  using (
    auth.role() = 'authenticated'
    and (
      staff_id = auth.uid()
      or public.get_user_role() in ('owner', 'manager', 'supervisor', 'admin')
    )
  );

create policy "payouts_insert_own"
  on public.payouts for insert
  with check (
    auth.role() = 'authenticated'
    and staff_id = auth.uid()
  );

create policy "payouts_update_own_or_manager"
  on public.payouts for update
  using (
    auth.role() = 'authenticated'
    and (
      staff_id = auth.uid()
      or public.get_user_role() in ('owner', 'manager', 'supervisor', 'admin')
    )
  );

-- ============================================================
-- SETTINGS — read all; write only manager/owner
-- ============================================================
drop policy if exists "settings_write" on public.settings;

-- keep existing settings_read_all and settings_write_admin
-- just drop the wide open one

-- ============================================================
-- ATTENDANCE — staff see own; managers see all
-- ============================================================
drop policy if exists "attendance_read" on public.attendance;
drop policy if exists "attendance_insert" on public.attendance;
drop policy if exists "attendance_update" on public.attendance;

create policy "attendance_select_own_or_manager"
  on public.attendance for select
  using (
    auth.role() = 'authenticated'
    and (
      staff_id = auth.uid()
      or public.get_user_role() in ('owner', 'manager', 'supervisor', 'admin')
    )
  );

create policy "attendance_insert_own"
  on public.attendance for insert
  with check (
    auth.role() = 'authenticated'
    and staff_id = auth.uid()
  );

create policy "attendance_update_own_or_manager"
  on public.attendance for update
  using (
    auth.role() = 'authenticated'
    and (
      staff_id = auth.uid()
      or public.get_user_role() in ('owner', 'manager', 'supervisor', 'admin')
    )
  );

-- ============================================================
-- VOID LOG — keep permissive for now (already scoped to authenticated)
-- ============================================================
-- void_log policies already require authenticated, which is adequate.
-- Consolidate duplicates if needed.
drop policy if exists "void_insert" on public.void_log;
drop policy if exists "void_read" on public.void_log;

-- ============================================================
-- GAME SALES / SHISHA SALES — currently wide open; restrict
-- ============================================================
drop policy if exists "game_sales_all" on public.game_sales;
drop policy if exists "shisha_sales_all" on public.shisha_sales;

create policy "game_sales_read_write_authenticated"
  on public.game_sales for all
  using (
    auth.role() = 'authenticated'
  )
  with check (
    auth.role() = 'authenticated'
  );

create policy "shisha_sales_read_write_authenticated"
  on public.shisha_sales for all
  using (
    auth.role() = 'authenticated'
  )
  with check (
    auth.role() = 'authenticated'
  );

-- ============================================================
-- GAME TYPES — keep read-only for authenticated; restrict write
-- ============================================================
drop policy if exists "game_types_all" on public.game_types;

create policy "game_types_read_authenticated"
  on public.game_types for select
  using (auth.role() = 'authenticated');

create policy "game_types_write_owner_manager"
  on public.game_types for insert
  with check (
    auth.role() = 'authenticated'
    and public.get_user_role() in ('owner', 'manager', 'admin')
  );

create policy "game_types_update_owner_manager"
  on public.game_types for update
  using (
    auth.role() = 'authenticated'
    and public.get_user_role() in ('owner', 'manager', 'admin')
  );

create policy "game_types_delete_owner_manager"
  on public.game_types for delete
  using (
    auth.role() = 'authenticated'
    and public.get_user_role() in ('owner', 'manager', 'admin')
  );

-- ============================================================
-- DEBTORS — restrict update to manager+specific staff id
-- ============================================================
drop policy if exists "debtors_update" on public.debtors;

create policy "debtors_update_own_or_manager"
  on public.debtors for update
  using (
    auth.role() = 'authenticated'
  )
  with check (
    auth.role() = 'authenticated'
    and (
      staff_id = auth.uid()
      or public.get_user_role() in ('owner', 'manager', 'supervisor', 'admin')
    )
  );
