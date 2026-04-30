CREATE TRIGGER bed_u_update_timestamp BEFORE UPDATE ON hpi.bed FOR EACH ROW EXECUTE FUNCTION hpi.fn_update_timestamp();
