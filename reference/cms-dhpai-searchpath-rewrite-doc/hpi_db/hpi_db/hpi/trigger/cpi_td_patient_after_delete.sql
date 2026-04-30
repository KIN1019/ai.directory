CREATE TRIGGER cpi_td_patient_after_delete AFTER DELETE ON hpi.cpi_patient REFERENCING OLD TABLE AS deleted FOR EACH STATEMENT EXECUTE FUNCTION hpi.fn_cpi_td_patient();
