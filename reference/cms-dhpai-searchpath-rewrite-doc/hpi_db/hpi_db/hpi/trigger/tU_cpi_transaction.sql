CREATE TRIGGER tU_cpi_transaction AFTER UPDATE ON hpi.cpi_transaction  REFERENCING OLD TABLE AS deleted NEW TABLE AS inserted FOR EACH STATEMENT EXECUTE FUNCTION hpi."fn_tU_cpi_transaction"();
