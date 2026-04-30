CREATE TRIGGER ops_tu_op_clt_after_update AFTER UPDATE ON hpi.op_clt REFERENCING OLD TABLE AS deleted NEW TABLE AS inserted FOR EACH STATEMENT EXECUTE FUNCTION hpi.fn_ops_tu_op_clt();
