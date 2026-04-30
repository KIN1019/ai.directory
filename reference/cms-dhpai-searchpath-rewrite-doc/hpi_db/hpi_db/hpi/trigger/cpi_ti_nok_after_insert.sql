CREATE TRIGGER cpi_ti_nok_after_insert AFTER INSERT ON hpi.cpi_nok REFERENCING NEW TABLE AS inserted FOR EACH STATEMENT EXECUTE FUNCTION hpi.fn_cpi_ti_nok();
