CREATE TRIGGER merge_hkid_i_update_timestamp BEFORE INSERT ON hpi.merge_hkid FOR EACH ROW EXECUTE FUNCTION hpi.fn_update_timestamp();
