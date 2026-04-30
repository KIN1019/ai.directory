CREATE TRIGGER cpi_case_u_update_timestamp BEFORE UPDATE ON hpi.cpi_case FOR EACH ROW EXECUTE FUNCTION hpi.fn_update_timestamp();
