CREATE TRIGGER cpi_patient_hospital_data_i_update_timestamp BEFORE INSERT ON hpi.cpi_patient_hospital_data FOR EACH ROW EXECUTE FUNCTION hpi.fn_update_timestamp();
