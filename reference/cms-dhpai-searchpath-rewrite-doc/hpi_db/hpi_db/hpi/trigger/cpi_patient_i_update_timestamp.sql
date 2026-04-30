CREATE TRIGGER cpi_patient_i_update_timestamp BEFORE INSERT ON hpi.cpi_patient FOR EACH ROW EXECUTE FUNCTION hpi.fn_update_timestamp();
