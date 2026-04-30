CREATE TRIGGER cpi_patient_u_update_timestamp BEFORE UPDATE ON hpi.cpi_patient FOR EACH ROW EXECUTE FUNCTION hpi.fn_update_timestamp();
