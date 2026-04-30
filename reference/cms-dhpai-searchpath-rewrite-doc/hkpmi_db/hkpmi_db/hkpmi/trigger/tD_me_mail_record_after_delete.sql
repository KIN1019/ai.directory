CREATE TRIGGER "tD_me_mail_record_after_delete"
AFTER DELETE
ON me_mail_record
REFERENCING OLD TABLE AS deleted
FOR EACH STATEMENT EXECUTE PROCEDURE "fn_tD_me_mail_record"();