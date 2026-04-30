CREATE TRIGGER cpi_ti_new_born_after_insert AFTER INSERT ON hpi.cpi_new_born REFERENCING NEW TABLE AS inserted FOR EACH STATEMENT EXECUTE FUNCTION hpi.fn_cpi_ti_new_born();
