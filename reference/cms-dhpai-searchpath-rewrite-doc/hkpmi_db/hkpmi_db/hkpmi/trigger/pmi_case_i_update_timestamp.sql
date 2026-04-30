CREATE TRIGGER pmi_case_i_update_timestamp BEFORE INSERT ON hkpmi.pmi_case FOR EACH ROW EXECUTE FUNCTION hkpmi.fn_update_timestamp();
