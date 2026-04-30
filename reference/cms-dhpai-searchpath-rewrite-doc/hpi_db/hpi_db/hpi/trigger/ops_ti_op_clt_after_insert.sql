CREATE TRIGGER ops_ti_op_clt_after_insert AFTER INSERT ON hpi.op_clt REFERENCING NEW TABLE AS inserted FOR EACH STATEMENT EXECUTE FUNCTION hpi.fn_ops_ti_op_clt();
