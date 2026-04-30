CREATE TRIGGER dp_attendence_u_update_timestamp BEFORE UPDATE ON hpi.dp_attendence FOR EACH ROW EXECUTE FUNCTION hpi.fn_update_timestamp();
