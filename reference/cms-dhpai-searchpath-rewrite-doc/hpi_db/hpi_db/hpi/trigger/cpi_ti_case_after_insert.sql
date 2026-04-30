CREATE TRIGGER cpi_ti_case_after_insert AFTER INSERT ON hpi.cpi_case REFERENCING NEW TABLE AS inserted FOR EACH STATEMENT EXECUTE FUNCTION hpi.fn_cpi_ti_case();
