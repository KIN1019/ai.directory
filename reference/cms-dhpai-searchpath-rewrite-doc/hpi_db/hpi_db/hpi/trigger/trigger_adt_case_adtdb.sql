-- create trigger on adt_case_adtdb
CREATE OR REPLACE TRIGGER trigger_adt_case_adtdb
    AFTER INSERT OR UPDATE OR DELETE ON
    adt_case_adtdb
    FOR EACH ROW
EXECUTE FUNCTION function_adt_case_adtdb();