CREATE TRIGGER cpi_nok_i_update_timestamp BEFORE INSERT ON hpi.cpi_nok FOR EACH ROW EXECUTE FUNCTION hpi.fn_update_timestamp();
