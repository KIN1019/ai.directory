CREATE TRIGGER dnl_exception_u_update_timestamp BEFORE UPDATE ON hpi.dnl_exception FOR EACH ROW EXECUTE FUNCTION hpi.fn_update_timestamp();
