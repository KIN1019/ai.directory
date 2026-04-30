CREATE TRIGGER ward_list_i_update_timestamp BEFORE INSERT ON hpi.ward_list FOR EACH ROW EXECUTE FUNCTION hpi.fn_update_timestamp();
