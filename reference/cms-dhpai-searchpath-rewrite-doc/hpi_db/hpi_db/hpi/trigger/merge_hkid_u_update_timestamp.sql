CREATE TRIGGER merge_hkid_u_update_timestamp BEFORE UPDATE ON hpi.merge_hkid FOR EACH ROW EXECUTE FUNCTION hpi.fn_update_timestamp();
