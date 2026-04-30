CREATE TRIGGER dp_attendence_i_update_timestamp BEFORE INSERT ON hpi.dp_attendence FOR EACH ROW EXECUTE FUNCTION hpi.fn_update_timestamp();
