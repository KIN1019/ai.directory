CREATE TRIGGER dnl_exception_i_update_timestamp BEFORE INSERT ON hpi.dnl_exception FOR EACH ROW EXECUTE FUNCTION hpi.fn_update_timestamp();
