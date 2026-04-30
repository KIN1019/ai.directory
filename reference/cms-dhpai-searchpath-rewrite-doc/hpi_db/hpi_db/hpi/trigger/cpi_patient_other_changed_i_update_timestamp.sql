CREATE TRIGGER cpi_patient_other_changed_i_update_timestamp BEFORE INSERT ON hpi.cpi_patient_other_changed FOR EACH ROW EXECUTE FUNCTION hpi.fn_update_timestamp();
