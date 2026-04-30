-- DROP FUNCTION hkpmi.hcrspq_gethkpmi_episall(varchar, varchar, varchar, int4);

CREATE OR REPLACE FUNCTION hkpmi.hcrspq_gethkpmi_episall(par_hkid character varying, par_hospital_code character varying, par_case_type character varying, par_dft_row_count integer DEFAULT 50)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
declare p_refcur refcursor;
DECLARE
    var_patient_key VARCHAR(8);
    /* Ronde LEUNG 4 Aug 1997 (begin) */
    var__hospital_code VARCHAR(3);
    var__case_no VARCHAR(12);
    var__case_type VARCHAR(1);
    var__admission_dtm TIMESTAMP WITHOUT TIME ZONE;
    var__discharge_code VARCHAR(1);
    var__discharge_dtm TIMESTAMP WITHOUT TIME ZONE;
    var__destination_code VARCHAR(3);
    var__last_specialty VARCHAR(4);
    var__last_sub_specialty VARCHAR(4);
    var__last_ward_code VARCHAR(4);
    var__last_ward_class VARCHAR(1);
    var__last_bed_no VARCHAR(5);
    var__status_code VARCHAR(2);
    /* Ronde LEUNG 4 Aug 1997 (end) */
    var__hcrs_patient_id VARCHAR(16);
    /* Cheung on 30/10/97 */
    var__hcrs_case_no VARCHAR(17);
    /* Cheung on 30/10/97 */
    var__update_dtm TIMESTAMP WITHOUT TIME ZONE;
    /* Cheung on 30/10/97 */
    var__sync_flag VARCHAR(1);
    /* Cheung on 30/10/97 */
    var__reg_flag VARCHAR(1);
BEGIN
    /* Cheung on 30/10/97 */
    SELECT
        NULL,
        /* Ronde LEUNG 4 Aug 1997 (begin) */
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        /* Ronde LEUNG 4 Aug 1997 (end) */
        NULL,
        /* Cheung on 30/10/97 */
        NULL,
        /* Cheung on 30/10/97 */
        NULL,
        /* Cheung on 30/10/97 */
        NULL,
        /* Cheung on 30/10/97 */
        NULL
        INTO var_patient_key, var__hospital_code, var__case_no, var__case_type, var__admission_dtm, var__discharge_code, var__discharge_dtm, var__destination_code, var__last_specialty, var__last_sub_specialty, var__last_ward_code, var__last_ward_class, var__last_bed_no, var__status_code, var__hcrs_patient_id, var__hcrs_case_no, var__update_dtm, var__sync_flag, var__reg_flag;
    /* Cheung on 30/10/97 */
    /* Cheung, start on 19/6/97 */
    /* Trim all input arguments */
    SELECT
        LTRIM(RTRIM(par_hkid)), LTRIM(RTRIM(par_hospital_code)), LTRIM(RTRIM(par_case_type))
        INTO par_hkid, par_hospital_code, par_case_type;
    /* end on 19/6/97 */

    IF par_hkid IS NULL THEN
        BEGIN
            SELECT
                'mnulhkid'
                INTO var_patient_key;
            /*
            Ronde LEUNG 4 Aug 1997 (begin)
            select	@patient_key	patient_key		,
            	null		hospital_code		,
            	null		case_no			,
            	null		case_type		,
            	null		admission_dtm		,
            	null		discharge_code		,
            	null		discharge_dtm		,
            	null		destination_code	,
            	null		last_specialty		,
            	null		last_sub_specialty	,
            	null		last_ward_code		,
            	null		last_ward_class		,
            	null		last_bed_no		,
            	null		status_code				/* Ronde LEUNG 27 Jun 1997 */
            ** Ronde LEUNG 4 Aug 1997 (end)
            */
            OPEN p_refcur FOR
            SELECT
                var_patient_key AS patient_key, var__hospital_code AS hospital_code, var__case_no AS case_no, var__case_type AS case_type, var__admission_dtm AS admission_dtm, var__discharge_code AS discharge_code, var__discharge_dtm AS discharge_dtm, var__destination_code AS destination_code, var__last_specialty AS last_specialty, var__last_sub_specialty AS last_sub_specialty, var__last_ward_code AS last_ward_code, var__last_ward_class AS last_ward_class, var__last_bed_no AS last_bed_no, var__status_code AS status_code, var__hcrs_patient_id AS hcrs_patient_id,
                /* Cheung on 30/10/97 */
                var__hcrs_case_no AS hcrs_case_no,
                /* Cheung on 30/10/97 */
                var__update_dtm AS update_dtm,
                /* Cheung on 30/10/97 */
                var__sync_flag AS sync_flag,
                /* Cheung on 30/10/97 */
                var__reg_flag AS reg_flag;
            /* Cheung on 30/10/97 */
           	return next p_refcur;
            RETURN;
        END;
    ELSE
        BEGIN
            IF OCTET_LENGTH(par_hkid) < 9 THEN
                BEGIN
                    SELECT
                        CONCAT(' ', par_hkid)
                        INTO par_hkid;
                END;
            END IF;
        END;
    END IF;

    IF par_hospital_code IS NULL THEN
        BEGIN
            SELECT
                'mnulhosp'
                INTO var_patient_key;
            /*
            Ronde LEUNG 4 Aug 1997 (begin)
            select	@patient_key	patient_key		,
            	null		hospital_code		,
            	null		case_no			,
            	null		case_type		,
            	null		admission_dtm		,
            	null		discharge_code		,
            	null		discharge_dtm		,
            	null		destination_code	,
            	null		last_specialty		,
            	null		last_sub_specialty	,
            	null		last_ward_code		,
            	null		last_ward_class		,
            	null		last_bed_no		,
            	null		status_code				/* Ronde LEUNG 27 Jun 1997 */
            ** Ronde LEUNG 4 Aug 1997 (end)
            */
            OPEN p_refcur FOR
            SELECT
                var_patient_key AS patient_key, var__hospital_code AS hospital_code, var__case_no AS case_no, var__case_type AS case_type, var__admission_dtm AS admission_dtm, var__discharge_code AS discharge_code, var__discharge_dtm AS discharge_dtm, var__destination_code AS destination_code, var__last_specialty AS last_specialty, var__last_sub_specialty AS last_sub_specialty, var__last_ward_code AS last_ward_code, var__last_ward_class AS last_ward_class, var__last_bed_no AS last_bed_no, var__status_code AS status_code, var__hcrs_patient_id AS hcrs_patient_id,
                /* Cheung on 30/10/97 */
                var__hcrs_case_no AS hcrs_case_no,
                /* Cheung on 30/10/97 */
                var__update_dtm AS update_dtm,
                /* Cheung on 30/10/97 */
                var__sync_flag AS sync_flag,
                /* Cheung on 30/10/97 */
                var__reg_flag AS reg_flag;
            /* Cheung on 30/10/97 */
           	return next p_refcur;
            RETURN;
        END;
    END IF;
    SELECT
        patient_key
        INTO var_patient_key
        FROM patient
        WHERE hkid = par_hkid;

    IF var_patient_key IS NULL OR LTRIM(RTRIM(var_patient_key)) IS NULL THEN
        BEGIN
            SELECT
                'mnulpkey'
                INTO var_patient_key;
            /*
            Ronde LEUNG 4 Aug 1997 (begin)
            select	@patient_key		patient_key		,
            	null			hospital_code		,
            	null			case_no			,
            	null			case_type		,
            	null			admission_dtm		,
            	null			discharge_code		,
            	null			discharge_dtm		,
            	null			destination_code	,
            	null			last_specialty		,
            	null			last_sub_specialty	,
            	null			last_ward_code		,
            	null			last_ward_class		,
            	null			last_bed_no		,
            	null			status_code			/* Ronde LEUNG 27 Jun 1997 */
            ** Ronde LEUNG 4 Aug 1997 (end)
            */
            OPEN p_refcur FOR
            SELECT
                var_patient_key AS patient_key, var__hospital_code AS hospital_code, var__case_no AS case_no, var__case_type AS case_type, var__admission_dtm AS admission_dtm, var__discharge_code AS discharge_code, var__discharge_dtm AS discharge_dtm, var__destination_code AS destination_code, var__last_specialty AS last_specialty, var__last_sub_specialty AS last_sub_specialty, var__last_ward_code AS last_ward_code, var__last_ward_class AS last_ward_class, var__last_bed_no AS last_bed_no, var__status_code AS status_code, var__hcrs_patient_id AS hcrs_patient_id,
                /* Cheung on 30/10/97 */
                var__hcrs_case_no AS hcrs_case_no,
                /* Cheung on 30/10/97 */
                var__update_dtm AS update_dtm,
                /* Cheung on 30/10/97 */
                var__sync_flag AS sync_flag,
                /* Cheung on 30/10/97 */
                var__reg_flag AS reg_flag;
            /* Cheung on 30/10/97 */
           	return next p_refcur;
            RETURN;
        END;
    END IF;

    IF par_case_type IS NULL THEN
        BEGIN
            /*
            [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 50 clause of SET statement is not supported. Perform a manual conversion.]
            set rowcount 50
            */
            /* Cheung on 15-Oct-1998	-- Michael on 7-June-2004 SCR:1544 */
            OPEN p_refcur FOR
            /* --			@patient_key		patient_key		,	-- whkwok on 18/6/97 */
            /*
            8-Jul-2005 By Lapres SCR:1838 (Begin)
            ** replace adm_specialty_code with last_specialty_code and match column name with CPI result set
            			c.patient_key					,	-- Cheung on 17-Oct-1998
            			c.hospital_code					,
            			ltrim(c.case_no)	case_no			,
            			c.case_type					,
            			c.adm_dtm					,
            			c.discharge_code				,
            			c.discharge_dtm					,
            			c.destination_code				,
            			c.adm_specialty_code				,
            			c.last_specialty_code				,
            			c.last_ward_code				,
            			c.last_ward_class				,
            			c.last_bed_no					,
            */
            SELECT
                c.patient_key AS patient_key, c.hospital_code AS hospital_code, LTRIM(c.case_no) AS case_no, c.case_type AS case_type, c.adm_dtm AS admission_dtm, c.discharge_code AS discharge_code, c.discharge_dtm AS discharge_dtm, c.destination_code AS destination_code, c.last_specialty_code AS last_specialty, '' AS last_sub_specialty,
                /* sub specialty code not support in MPI */
                c.last_ward_code AS last_ward_code, c.last_ward_class AS last_ward_class, c.last_bed_no AS last_bed_no,
                /* (End) SCR:1838 */
                'AC' AS status_code, /* Ronde LEUNG 27 Jun 1997 */ var__hcrs_patient_id AS hcrs_patient_id,
                /* Cheung on 30/10/97 */
                var__hcrs_case_no AS hcrs_case_no,
                /* Cheung on 30/10/97 */
                var__update_dtm AS update_dtm,
                /* Cheung on 30/10/97 */
                var__sync_flag AS sync_flag,
                /* Cheung on 30/10/97 */
                var__reg_flag AS reg_flag
                /* Cheung on 30/10/97 */
                FROM pmi_case AS c
                WHERE c.patient_key = var_patient_key AND c.hospital_code = par_hospital_code
                /* Remarked by Cheung on 29/12/1997 (begin) */
                
                /* --	and		not ((c.case_type = "A" or c.case_type = "I" or c.case_type = "D") */
                
                /* --	and		c.discharge_dtm <> null) */
                /* Remarked by Cheung on 29/12/1997 (end) */
                ORDER BY c.adm_dtm DESC NULLS FIRST, c.case_no DESC NULLS FIRST limit par_dft_row_count;
		return next p_refcur;
            /*
            [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 0 clause of SET statement is not supported. Perform a manual conversion.]
            set rowcount 0
            */
        END;
    ELSE
        BEGIN
            /*
            [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 50 clause of SET statement is not supported. Perform a manual conversion.]
            set rowcount 50
            */
            /* Cheung on 15-Oct-1998	-- Michael on 7-June-2004 SCR:1544 */
            OPEN p_refcur FOR
            /* --			@patient_key		patient_key		,	-- whkwok on 18/6/97 */
            /*
            8-Jul-2005 By Lapres SCR:1838 (Begin)
            ** replace adm_specialty_code with last_specialty_code and match column name with CPI result set
            			c.patient_key					,	-- Cheung on 17-Oct-1998
            			c.hospital_code					,
            			ltrim(c.case_no)	case_no			,
            			c.case_type					,
            			c.adm_dtm					,
            			c.discharge_code				,
            			c.discharge_dtm					,
            			c.destination_code				,
            			c.adm_specialty_code				,
            			c.last_specialty_code				,
            			c.last_ward_code				,
            			c.last_ward_class				,
            			c.last_bed_no					,
            */
            SELECT
                c.patient_key AS patient_key, c.hospital_code AS hospital_code, LTRIM(c.case_no) AS case_no, c.case_type AS case_type, c.adm_dtm AS admission_dtm, c.discharge_code AS discharge_code, c.discharge_dtm AS discharge_dtm, c.destination_code AS destination_code, c.last_specialty_code AS last_specialty, '' AS last_sub_specialty,
                /* sub specialty code not support in MPI */
                c.last_ward_code AS last_ward_code, c.last_ward_class AS last_ward_class, c.last_bed_no AS last_bed_no,
                /* (End) SCR:1838 */
                'AC' AS status_code, /* Ronde LEUNG 27 Jun 1997 */ var__hcrs_patient_id AS hcrs_patient_id,
                /* Cheung on 30/10/97 */
                var__hcrs_case_no AS hcrs_case_no,
                /* Cheung on 30/10/97 */
                var__update_dtm AS update_dtm,
                /* Cheung on 30/10/97 */
                var__sync_flag AS sync_flag,
                /* Cheung on 30/10/97 */
                var__reg_flag AS reg_flag
                /* Cheung on 30/10/97 */
                FROM pmi_case AS c
                WHERE c.patient_key = var_patient_key AND c.hospital_code = par_hospital_code AND c.case_type = par_case_type
                /* Remarked by Cheung on 29/12/1997 (begin) */
                
                /* --	and	not ((c.case_type = "A" or c.case_type = "I" or c.case_type = "D") */
                
                /* --	and	c.discharge_dtm <> null) */
                /* Remarked by Cheung on 29/12/1997 (end) */
                ORDER BY c.adm_dtm DESC NULLS FIRST, c.case_no DESC NULLS FIRST limit par_dft_row_count;
			return next p_refcur;
            /*
            [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 0 clause of SET statement is not supported. Perform a manual conversion.]
            set rowcount 0
            */
        END;
    END IF;
END;
$function$
;


ALTER FUNCTION "hcrspq_gethkpmi_episall" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

