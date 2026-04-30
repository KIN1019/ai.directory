CREATE TRIGGER cpi_patient_hospital_data_u_update_timestamp BEFORE UPDATE ON hpi.cpi_patient_hospital_data FOR EACH ROW EXECUTE FUNCTION hpi.fn_update_timestamp();
