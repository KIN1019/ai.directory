CREATE TRIGGER borrowers_u_update_timestamp BEFORE UPDATE ON hpi.borrowers FOR EACH ROW EXECUTE FUNCTION hpi.fn_update_timestamp();
