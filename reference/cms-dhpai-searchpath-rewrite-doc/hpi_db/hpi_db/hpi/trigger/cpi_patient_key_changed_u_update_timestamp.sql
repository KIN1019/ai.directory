CREATE TRIGGER cpi_patient_key_changed_u_update_timestamp BEFORE UPDATE ON hpi.cpi_patient_key_changed FOR EACH ROW EXECUTE FUNCTION hpi.fn_update_timestamp();
