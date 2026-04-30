CREATE TRIGGER "td_me_mail_conf_after_delete"
AFTER DELETE
ON me_mail_conf
REFERENCING OLD TABLE AS deleted
FOR EACH STATEMENT EXECUTE PROCEDURE "fn_tD_me_mail_conf"();