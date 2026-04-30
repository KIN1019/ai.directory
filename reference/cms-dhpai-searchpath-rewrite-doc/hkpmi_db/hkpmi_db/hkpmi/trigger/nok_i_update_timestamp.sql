CREATE TRIGGER nok_i_update_timestamp BEFORE INSERT ON hkpmi.nok FOR EACH ROW EXECUTE FUNCTION hkpmi.fn_update_timestamp();
