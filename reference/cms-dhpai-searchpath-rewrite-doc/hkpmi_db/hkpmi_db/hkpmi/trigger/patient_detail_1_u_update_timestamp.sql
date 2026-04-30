CREATE TRIGGER patient_detail_1_u_update_timestamp BEFORE UPDATE ON hkpmi.patient_detail_1 FOR EACH ROW EXECUTE FUNCTION hkpmi.fn_update_timestamp();
