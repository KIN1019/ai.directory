-- DROP PROCEDURE cpi_pq_validate_spec(inout int4, in varchar, in varchar, in varchar, in timestamp, inout varchar);

CREATE OR REPLACE PROCEDURE cpi_pq_validate_spec(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_specialty_code character varying, IN par_case_type character varying, IN par_validate_datetime timestamp without time zone, INOUT par_valid_flag character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_cnt INTEGER;
    var_cur_date TIMESTAMP WITHOUT TIME ZONE;
BEGIN
    IF ((par_case_type != 'I') AND (par_case_type != 'O')) OR par_case_type IS NULL THEN
        BEGIN
            SELECT
                'N'
                INTO par_valid_flag;
            pas_return_code := 0;
            RETURN;
        END;
    END IF;
    /*
    if (@case_type = 'I')
    	select	@cnt = count(*)
    	from	ip_specialty
    	where	hospital_code = @hospital_code
    	and	specialty_code = @specialty_code
    	and	open_date <= @validate_datetime
    	and	(@validate_datetime < close_date
    	or	close_date is null)
    else
    	select	@cnt = count(*)
    	from	op_specialty
    	where	hospital_code = @hospital_code
    	and	specialty_code = @specialty_code
    
    if (@cnt = 1)
    	select @valid_flag = 'Y'
    else
    	select @valid_flag = 'N'
    */
    /* No checking until ADT is ready */
    SELECT
        'Y'
        INTO par_valid_flag;
    pas_return_code := 0;
    RETURN;
END;
$procedure$
;


;ALTER PROCEDURE "cpi_pq_validate_spec" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
