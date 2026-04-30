CREATE TRIGGER cpi_case_i_update_timestamp BEFORE INSERT ON hpi.cpi_case FOR EACH ROW EXECUTE FUNCTION hpi.fn_update_timestamp();
