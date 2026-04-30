CREATE TRIGGER patient_i_update_timestamp BEFORE INSERT ON hkpmi.patient FOR EACH ROW EXECUTE FUNCTION hkpmi.fn_update_timestamp();
