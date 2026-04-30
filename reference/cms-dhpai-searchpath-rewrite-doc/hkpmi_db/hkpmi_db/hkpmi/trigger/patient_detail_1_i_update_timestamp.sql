CREATE TRIGGER patient_detail_1_i_update_timestamp BEFORE INSERT ON hkpmi.patient_detail_1 FOR EACH ROW EXECUTE FUNCTION hkpmi.fn_update_timestamp();
