CREATE OR REPLACE TRIGGER trigger_cpi_active_case
    AFTER INSERT OR UPDATE OR DELETE ON
    cpi_active_case
    FOR EACH ROW
EXECUTE FUNCTION function_cpi_active_case();