CREATE TRIGGER cpi_access_changed_i_update_timestamp BEFORE INSERT ON hpi.cpi_access_changed FOR EACH ROW EXECUTE FUNCTION hpi.fn_update_timestamp();
