CREATE TRIGGER cpi_tu_nok_after_update AFTER UPDATE ON hpi.cpi_nok REFERENCING OLD TABLE AS deleted NEW TABLE AS inserted FOR EACH STATEMENT EXECUTE FUNCTION hpi.fn_cpi_tu_nok();
