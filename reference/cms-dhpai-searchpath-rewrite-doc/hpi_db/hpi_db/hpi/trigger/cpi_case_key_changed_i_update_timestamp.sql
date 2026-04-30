CREATE TRIGGER cpi_case_key_changed_i_update_timestamp BEFORE INSERT ON hpi.cpi_case_key_changed FOR EACH ROW EXECUTE FUNCTION hpi.fn_update_timestamp();
