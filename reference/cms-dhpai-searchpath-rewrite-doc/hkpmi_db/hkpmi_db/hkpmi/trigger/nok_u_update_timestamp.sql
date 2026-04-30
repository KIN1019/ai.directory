CREATE TRIGGER nok_u_update_timestamp BEFORE UPDATE ON hkpmi.nok FOR EACH ROW EXECUTE FUNCTION hkpmi.fn_update_timestamp();
