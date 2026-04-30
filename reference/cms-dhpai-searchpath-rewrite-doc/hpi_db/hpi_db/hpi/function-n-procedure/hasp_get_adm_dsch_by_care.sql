CREATE OR REPLACE PROCEDURE hasp_get_adm_dsch_by_care(INOUT pas_return_code int, IN par_hospital_code VARCHAR, IN par_from_date TIMESTAMP WITHOUT TIME ZONE, IN par_to_date TIMESTAMP WITHOUT TIME ZONE, IN par_care_category VARCHAR)
AS 
$BODY$
DECLARE
    var_error INTEGER;
    var_rowcount INTEGER;
    var_errarg VARCHAR(80);
    var_local_server VARCHAR(48);
    var_report_server VARCHAR(48);
    var_prog_name VARCHAR(80);
    var_db_name VARCHAR(48);
    var_hospital VARCHAR(6);
    sql$rowcount BIGINT;
BEGIN
    /*
    Admission and Discharge Summary By Specialty By Care Category
    
    parameter name          Description
    @hospital_code				Hospital code
    @from_date					From date to be processed
    @to_date						To date to be processed
    @spec							Required ward code
    */
    /*
    [3014 - Severity CRITICAL - PostgreSQL doesn't support the @@SERVERNAME function. Use suitable function or create user defined function.]
    select @local_server = @@servername
    */
    SELECT
        'hasp_get_adds_by_care_report'
        INTO var_prog_name;
    SELECT
        Text_value
        INTO var_report_server
        FROM Hospital_control
        WHERE Type = 'REPORT_SERVER_NAME' AND Hospital_code = par_hospital_code;
    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

    IF sql$rowcount <> 1 THEN
        SELECT
            NULL
            INTO var_report_server;
    END IF;

    IF ((var_report_server IS NULL OR var_local_server IS NULL) AND (var_local_server IS NOT NULL OR var_report_server IS NOT NULL)) OR var_local_server <> var_report_server THEN
        BEGIN
            /* --		select @hospital = Hospital_code */
            /* --			from Hospital */
            SELECT
                CONCAT(RTRIM(LOWER(par_hospital_code)), 'hpi_db')
                INTO var_db_name;
            SELECT
                CONCAT(RTRIM(var_report_server), '.', RTRIM(var_db_name), '..', RTRIM(var_prog_name))
                INTO var_prog_name;
        END;
    END IF;
    /*
    [3029 - Severity CRITICAL - PostgreSQL doesn't support the execution of a procedure as a variable. Perform a manual conversion using dynamic SQL.]
    exec @prog_name @hospital_code, @from_date, @to_date, @care_category
    */
END;
$BODY$
LANGUAGE plpgsql;