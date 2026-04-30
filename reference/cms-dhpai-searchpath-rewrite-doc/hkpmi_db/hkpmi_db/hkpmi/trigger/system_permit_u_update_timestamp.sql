CREATE TRIGGER system_permit_u_update_timestamp BEFORE UPDATE ON hkpmi.system_permit FOR EACH ROW EXECUTE FUNCTION hkpmi.fn_update_timestamp();
