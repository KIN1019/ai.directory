CREATE TRIGGER patient_u_update_timestamp BEFORE UPDATE ON hkpmi.patient FOR EACH ROW EXECUTE FUNCTION hkpmi.fn_update_timestamp();
