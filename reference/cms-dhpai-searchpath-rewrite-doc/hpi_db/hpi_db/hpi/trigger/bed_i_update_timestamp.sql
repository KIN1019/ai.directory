CREATE TRIGGER bed_i_update_timestamp BEFORE INSERT ON hpi.bed FOR EACH ROW EXECUTE FUNCTION hpi.fn_update_timestamp();
