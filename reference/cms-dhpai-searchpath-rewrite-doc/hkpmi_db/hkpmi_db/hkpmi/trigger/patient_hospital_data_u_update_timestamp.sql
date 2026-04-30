CREATE TRIGGER patient_hospital_data_u_update_timestamp BEFORE UPDATE ON hkpmi.patient_hospital_data FOR EACH ROW EXECUTE FUNCTION hkpmi.fn_update_timestamp();
