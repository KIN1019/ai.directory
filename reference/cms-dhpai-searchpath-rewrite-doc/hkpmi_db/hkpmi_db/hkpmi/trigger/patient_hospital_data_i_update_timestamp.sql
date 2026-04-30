CREATE TRIGGER patient_hospital_data_i_update_timestamp BEFORE INSERT ON hkpmi.patient_hospital_data FOR EACH ROW EXECUTE FUNCTION hkpmi.fn_update_timestamp();
