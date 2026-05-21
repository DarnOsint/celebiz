-- RPC to securely migrate a PIN from PBKDF2 to plaintext
-- The app never sends the raw PIN to the DB from the client.
-- This RPC is called only when migrating from client-side PBKDF2,
-- and the PIN is stored as-is for the server-side RPC to verify.
-- Future: replace with pgcrypto crypt() if extension becomes available.
CREATE OR REPLACE FUNCTION migrate_pin_hash(staff_id uuid, new_pin text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  UPDATE profiles
  SET pin = new_pin
  WHERE id = staff_id
    AND is_active = true
    AND pin LIKE 'pbkdf2:%';
END;
$$;

REVOKE ALL ON FUNCTION migrate_pin_hash(uuid, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION migrate_pin_hash(uuid, text) TO authenticated;
