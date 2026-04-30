CREATE TRIGGER ward_list_u_update_timestamp BEFORE UPDATE ON hpi.ward_list FOR EACH ROW EXECUTE FUNCTION hpi.fn_update_timestamp();
