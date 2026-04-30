CREATE TRIGGER "tI_transaction_log_after_insert" AFTER INSERT ON download.transaction_log REFERENCING NEW TABLE AS inserted FOR EACH STATEMENT EXECUTE FUNCTION download."fn_tI_transaction_log"();
