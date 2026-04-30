CREATE TRIGGER cpi_ti_patient_hd_after_insert AFTER INSERT ON hpi.cpi_patient_hospital_data REFERENCING NEW TABLE AS inserted FOR EACH STATEMENT EXECUTE FUNCTION hpi.fn_cpi_ti_patient_hd();
