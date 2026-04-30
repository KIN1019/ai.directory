-- DROP PROCEDURE hpi.hasp_staying_age(inout int4, in bpchar, in timestamp, inout refcursor);

CREATE OR REPLACE PROCEDURE hpi.hasp_staying_age(INOUT pas_return_code integer, IN par_hosp_code character, IN par_end_date timestamp without time zone, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
/*
- Staying in hospital for the age >= 65
02.08.1999 - add hospital code for HPI by Mabel LAU
*/
DECLARE
    var_count               INTEGER;
    var_processing_datetime TIMESTAMP WITHOUT TIME ZONE;
BEGIN
    SELECT 1 * INTERVAL '1 day' + par_end_date::TIMESTAMP
    INTO var_processing_datetime;
    /*
    script before CPI update
    		  select @count=count(*) from Case c,PMI p
    updated by man at may 96
    */
    /* use PMI_wo_MRN and add hospital code for HPI */
    /* and remark Case_type by like ' HN%' condition */
    /* to speed up */
    /* by ML on 02.08.1999 */
    /* --select @count=count(*) from Case_view c, PMI p */
    SELECT COUNT(*)
    INTO var_count
    FROM Case_view AS c,
         PMI_wo_MRN AS p
    WHERE c.Admission_datetime < var_processing_datetime
      AND (c.Discharge_datetime >= var_processing_datetime OR c.Discharge_datetime is NULL)
      AND
        /* --and (c.Case_type = 'I') */
        (c.Case_no SIMILAR TO ' HN%')
      AND DATE_PART('year', var_processing_datetime::TIMESTAMP) - DATE_PART('year', p.DOB::TIMESTAMP) >= 65
      AND c.HKID = p.HKID
      AND c.Hospital_code = par_hosp_code;

    OPEN p_refcur FOR
        SELECT var_count;

    pas_return_code := 0;
END ;
$procedure$
;

;ALTER PROCEDURE "hasp_staying_age" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
