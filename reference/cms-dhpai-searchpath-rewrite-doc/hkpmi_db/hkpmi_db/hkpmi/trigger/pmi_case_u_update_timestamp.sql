CREATE TRIGGER pmi_case_u_update_timestamp BEFORE UPDATE ON hkpmi.pmi_case FOR EACH ROW EXECUTE FUNCTION hkpmi.fn_update_timestamp();
