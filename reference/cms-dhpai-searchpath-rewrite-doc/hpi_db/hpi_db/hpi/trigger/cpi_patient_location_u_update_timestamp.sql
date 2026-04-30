CREATE TRIGGER cpi_patient_location_u_update_timestamp BEFORE UPDATE ON hpi.cpi_patient_location FOR EACH ROW EXECUTE FUNCTION hpi.fn_update_timestamp();
