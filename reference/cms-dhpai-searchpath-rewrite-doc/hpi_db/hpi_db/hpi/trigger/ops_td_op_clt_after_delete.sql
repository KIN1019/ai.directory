CREATE TRIGGER ops_td_op_clt_after_delete AFTER DELETE ON hpi.op_clt REFERENCING OLD TABLE AS deleted FOR EACH STATEMENT EXECUTE FUNCTION hpi.fn_ops_td_op_clt();
