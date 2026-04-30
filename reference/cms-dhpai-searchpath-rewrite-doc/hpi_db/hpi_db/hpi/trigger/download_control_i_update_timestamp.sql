CREATE TRIGGER download_control_i_update_timestamp BEFORE INSERT ON hpi.download_control_pg FOR EACH ROW EXECUTE FUNCTION hpi.fn_update_timestamp();
