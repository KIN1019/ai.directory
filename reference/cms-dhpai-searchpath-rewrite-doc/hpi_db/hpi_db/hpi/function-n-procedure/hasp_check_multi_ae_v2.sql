-- DROP PROCEDURE hpi.hasp_check_multi_ae_v2(inout int4, in varchar, in varchar, in timestamp);

CREATE OR REPLACE PROCEDURE hpi.hasp_check_multi_ae_v2(INOUT pas_return_code integer, IN par_hkid character varying, IN par_hosp_code character varying, IN par_reg_date timestamp without time zone)
 LANGUAGE plpgsql
AS $procedure$
/*
@reg_date datetime,
@multi_ae char(20)=null output,
@ha_rrpe char(20)=null output)
*/
DECLARE
    var_multi_type_a INTEGER;
    var_multi_type_m INTEGER;
    var_multi_type_c INTEGER;
    var_multi_type_h INTEGER;
    var_return_code INTEGER;
BEGIN
    /* init */
    SELECT
        0
        INTO var_multi_type_a;
    SELECT
        0
        INTO var_multi_type_m;
    SELECT
        0
        INTO var_multi_type_c;
    SELECT
        0
        INTO var_multi_type_h;
    SELECT
        0
        INTO var_return_code;
    /* --select @multi_ae="",@ha_rrpe="" */
    /* record for multi_type = A */
    IF EXISTS (SELECT
        *
        FROM ae_multi_registration
        WHERE hospital_code = par_hosp_code AND hkid = par_hkid AND effective_date <= par_reg_date AND multi_type = 'A' AND (close_date IS NULL OR close_date > par_reg_date)) THEN
        SELECT
            1
            INTO var_multi_type_a;
    END IF;
    /* record for multi_type = M */
    IF EXISTS (SELECT
        *
        FROM ae_multi_registration
        WHERE hospital_code = par_hosp_code AND hkid = par_hkid AND effective_date <= par_reg_date AND multi_type = 'M' AND (close_date IS NULL OR close_date > par_reg_date)) THEN
        SELECT
            2
            INTO var_multi_type_m;
    END IF;
    /* record for multi_type = C - CJD */
    IF EXISTS (SELECT
        *
        FROM ae_multi_registration
        WHERE hospital_code = par_hosp_code AND hkid = par_hkid AND effective_date <= par_reg_date AND multi_type = 'C' AND (close_date IS NULL OR close_date > par_reg_date)) THEN
        SELECT
            4
            INTO var_multi_type_c;
    END IF;
    /* record for multi_type =P -HAPPRE patient */
    IF EXISTS (SELECT
        hospital_code, hkid, multi_type
        FROM ae_multi_registration
        WHERE hospital_code = par_hosp_code AND hkid = par_hkid AND multi_type = 'P' AND effective_date <= par_reg_date
        AND (close_date IS NULL OR close_date > par_reg_date) 
        ORDER BY effective_date DESC
        LIMIT 1) THEN
        /*
        select @ha_rrpe="_HP"
        else
          select @ha_rrpe=""
        */
        SELECT
            8
            INTO var_multi_type_h;
    END IF;
    /*
    multi_type's combination
    *
    *       rc=0   -000 (@mutl_type_a + @multi_type_m + @multi_type_c= 0)
    *       rc=1   -001 (@multi_type_a=1 only)
    *       rc=2   -010 (@multi_type_m=2 only)
    *       rc=3   -011 (@mutl_type_a + @multi_type_m = 3)
    *       rc > 3 -1xx (@mutl_type_a + @multi_type_m + @multi_type_c > 3)
    *       rc>=8  - HP
    *           Note:@mult_type_c will overwrite @mult_type_a & @mult_type_m
    */
    SELECT
        var_multi_type_a + var_multi_type_m + var_multi_type_c + var_multi_type_h
        INTO var_return_code;
    /*
    if @return_code = 1
     select @multi_ae = "MULT-A"
    else if @return_code = 2
     select @multi_ae = "MULT-M"
    else if @return_code = 3
     select @multi_ae = "MULT-AM"
    else
     select @multi_ae = ""
    */
    pas_return_code := var_return_code;
    RETURN /* ----for OLD PBD version ONLY... */;
END;
$procedure$
;


;ALTER PROCEDURE "hasp_check_multi_ae_v2" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
