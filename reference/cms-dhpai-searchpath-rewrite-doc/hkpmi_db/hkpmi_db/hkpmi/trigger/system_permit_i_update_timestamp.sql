CREATE TRIGGER system_permit_i_update_timestamp BEFORE INSERT ON hkpmi.system_permit FOR EACH ROW EXECUTE FUNCTION hkpmi.fn_update_timestamp();
