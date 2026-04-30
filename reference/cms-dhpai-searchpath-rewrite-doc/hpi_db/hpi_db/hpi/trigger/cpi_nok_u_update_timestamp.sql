CREATE TRIGGER cpi_nok_u_update_timestamp BEFORE UPDATE ON hpi.cpi_nok FOR EACH ROW EXECUTE FUNCTION hpi.fn_update_timestamp();
