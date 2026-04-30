CREATE TRIGGER borrowers_i_update_timestamp BEFORE INSERT ON hpi.borrowers FOR EACH ROW EXECUTE FUNCTION hpi.fn_update_timestamp();
