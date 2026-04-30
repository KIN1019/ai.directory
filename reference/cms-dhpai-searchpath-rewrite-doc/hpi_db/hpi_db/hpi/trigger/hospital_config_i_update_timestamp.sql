CREATE TRIGGER hospital_config_i_update_timestamp BEFORE INSERT ON hpi.hospital_config FOR EACH ROW EXECUTE FUNCTION hpi.fn_update_timestamp();
