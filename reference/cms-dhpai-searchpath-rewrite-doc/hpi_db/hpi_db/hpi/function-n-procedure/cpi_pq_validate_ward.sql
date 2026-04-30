-- DROP PROCEDURE cpi_pq_validate_ward(inout int4, in varchar, in varchar, in varchar, in timestamp, inout varchar);

CREATE OR REPLACE PROCEDURE cpi_pq_validate_ward(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_ward_code character varying, IN par_ward_class character varying, IN par_validate_datetime timestamp without time zone, INOUT par_valid_flag character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_cnt INTEGER;
    var_cur_date TIMESTAMP WITHOUT TIME ZONE;
BEGIN
    /* Not check ward_class until ADT implement ward_class */
    /*
    select	@cnt = count(*)
    from	ward_class
    where	hospital_code = @hospital_code
    and	ward_code = @ward_code
    and	ward_class = @ward_class
    
    if (@cnt = 1)
    	select @valid_flag = 'Y'
    else
    begin
    	select	@cnt = count(*)
    	from	ward
    	where	hospital_code = @hospital_code
    	and	ward_code = @ward_code
    	and	open_date <= @validate_datetime
    	and 	(@validate_datetime < close_date
    	or	close_date is null)
    
    	if (@cnt = 0)
    		select @valid_flag = 'N'
    	else
    		select @valid_flag = 'Y'
    
    end
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


;ALTER PROCEDURE "cpi_pq_validate_ward" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
