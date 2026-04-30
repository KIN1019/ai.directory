DO $$
DECLARE
    next_val INT;
BEGIN
    DROP SEQUENCE IF EXISTS patient_key_exception_record_id CASCADE;
    SELECT COALESCE(MAX(record_id), 0) + 1 INTO next_val
    FROM patient_key_exception;
    EXECUTE FORMAT('CREATE SEQUENCE patient_key_exception_record_id START WITH %s;', next_val);
    ALTER SEQUENCE patient_key_exception_record_id OWNER TO "DOWNLOAD_SCHEMA_OWNER_ROLE";
    ALTER SEQUENCE patient_key_exception_record_id OWNED BY patient_key_exception.record_id;
    ALTER TABLE patient_key_exception
    ALTER COLUMN record_id SET DEFAULT nextval('patient_key_exception_record_id');
END $$;