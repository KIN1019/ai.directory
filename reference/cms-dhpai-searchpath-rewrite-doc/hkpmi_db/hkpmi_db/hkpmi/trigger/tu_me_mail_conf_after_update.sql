CREATE TRIGGER "tu_me_mail_conf_after_update"
AFTER UPDATE
ON me_mail_conf
REFERENCING OLD TABLE AS deleted NEW TABLE AS inserted
FOR EACH STATEMENT EXECUTE PROCEDURE "fn_tU_me_mail_conf"();