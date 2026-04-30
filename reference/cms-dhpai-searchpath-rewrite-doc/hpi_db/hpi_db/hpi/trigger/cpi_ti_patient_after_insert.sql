CREATE TRIGGER cpi_ti_patient_after_insert AFTER INSERT ON hpi.cpi_patient REFERENCING NEW TABLE AS inserted FOR EACH STATEMENT EXECUTE FUNCTION hpi.fn_cpi_ti_patient();
