CREATE TRIGGER hospital_config_u_update_timestamp BEFORE UPDATE ON hpi.hospital_config FOR EACH ROW EXECUTE FUNCTION hpi.fn_update_timestamp();
