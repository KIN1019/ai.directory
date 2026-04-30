CREATE TRIGGER cpi_access_changed_u_update_timestamp BEFORE UPDATE ON hpi.cpi_access_changed FOR EACH ROW EXECUTE FUNCTION hpi.fn_update_timestamp();
