-- DROP FUNCTION hkpmi.hcrspq_gethkpmi_episode(varchar, varchar);

CREATE OR REPLACE FUNCTION hkpmi.hcrspq_gethkpmi_episode(par_case_no character varying, par_hospital_code character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
declare p_refcur refcursor;
DECLARE
    var_patient_key VARCHAR(8);
    var_mrn VARCHAR(8);
    /* Ronde LEUNG 4 Aug 1997 (begin) */
    var__hkid VARCHAR(12);
    var__patient_name VARCHAR(48);
    var__sex VARCHAR(1);
    var__cccode1 VARCHAR(5);
    var__cccode2 VARCHAR(5);
    var__cccode3 VARCHAR(5);
    var__cccode4 VARCHAR(5);
    var__cccode5 VARCHAR(5);
    var__cccode6 VARCHAR(5);
    var__chi_name VARCHAR(12);
    var__dob TIMESTAMP WITHOUT TIME ZONE;
    var__exact_dob_flag VARCHAR(1);
    var__home_phone VARCHAR(14);
    var__office_phone VARCHAR(14);
    var__other_phone VARCHAR(14);
    var__death_indicator VARCHAR(1);
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
    var__hp_update_dtm TIMESTAMP WITHOUT TIME ZONE;
    /* Cheung on 30/10/97 */
    var__hc_update_dtm TIMESTAMP WITHOUT TIME ZONE;
    /* Cheung on 30/10/97 */
    var__hp_sync_flag VARCHAR(1);
    /* Cheung on 30/10/97 */
    var__hp_reg_flag VARCHAR(1);
    /* Cheung on 30/10/97 */
    var__hc_sync_flag VARCHAR(1);
    /* Cheung on 30/10/97 */
    var__hc_reg_flag VARCHAR(1);
    /* Cheung on 30/10/97 */
    var__patient_class SMALLINT;
BEGIN
    /* Cheung on 17-Oct-1998 */
    SELECT
        NULL, NULL,
        /* Ronde LEUNG 4 Aug 1997 (begin) */
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        /* Ronde LEUNG 4 Aug 1997 (end) */
        NULL,
        /* Cheung on 30/10/97 */
        NULL,
        /* Cheung on 30/10/97 */
        NULL,
        /* Cheung on 30/10/97 */
        NULL,
        /* Cheung on 30/10/97 */
        NULL,
        /* Cheung on 30/10/97 */
        NULL,
        /* Cheung on 30/10/97 */
        NULL,
        /* Cheung on 30/10/97 */
        NULL,
        /* Cheung on 30/10/97 */
        NULL
        INTO var_patient_key, var_mrn, var__hkid, var__patient_name, var__sex, var__cccode1, var__cccode2, var__cccode3, var__cccode4, var__cccode5, var__cccode6, var__chi_name, var__dob, var__exact_dob_flag, var__home_phone, var__office_phone, var__other_phone, var__death_indicator, var__hospital_code, var__case_no, var__case_type, var__admission_dtm, var__discharge_code, var__discharge_dtm, var__destination_code, var__last_specialty, var__last_sub_specialty, var__last_ward_code, var__last_ward_class, var__last_bed_no, var__status_code, var__hcrs_patient_id, var__hcrs_case_no, var__hp_update_dtm, var__hc_update_dtm, var__hp_sync_flag, var__hp_reg_flag, var__hc_sync_flag, var__hc_reg_flag, var__patient_class;
    /* Cheung on 17-Oct-1998 */
    /* Cheung, start on 19/6/97 */
    /* Trim all input arguments */
    SELECT
        LTRIM(RTRIM(par_case_no)), LTRIM(RTRIM(par_hospital_code))
        INTO par_case_no, par_hospital_code;
    /* end on 19/6/97 */

    IF par_case_no IS NULL THEN
        BEGIN
            SELECT
                'mnulcase'
                INTO var_patient_key;
            /*
            Ronde LEUNG 4 Aug 1997 (begin)
                    select
            			@patient_key patient_key ,null hkid ,null patient_name
            			,null sex ,null cccode1 ,null cccode2 ,null cccode3
            			,null cccode4 ,null cccode5 ,null cccode6
            			,null chi_name ,null dob ,null exact_dob_flag
            			,null home_phone ,null office_phone ,null other_phone
            			,null death_indicator
            			,null mrn
                        ,null hospital_code ,null case_no
            			,null case_type ,null admission_dtm ,null discharge_code
            			,null discharge_dtm ,null destination_code
            			,null last_specialty ,null last_sub_specialty
            			,null last_ward_code ,null last_ward_class ,null last_bed_no
            			,null status_code	/* Ronde LEUNG 27 Jun 1997 */
                    ** Ronde LEUNG 4 Aug 1997 (end)
            */
            OPEN p_refcur FOR
            SELECT
                var_patient_key AS patient_key, var__hkid AS hkid, var__patient_name AS patient_name, var__sex AS sex, var__cccode1 AS cccode1, var__cccode2 AS cccode2, var__cccode3 AS cccode3, var__cccode4 AS cccode4, var__cccode5 AS cccode5, var__cccode6 AS cccode6, var__chi_name AS chi_name, var__dob AS dob, var__exact_dob_flag AS exact_dob_flag, var__home_phone AS home_phone, var__office_phone AS office_phone, var__other_phone AS other_phone, var__death_indicator AS death_indicator, var_mrn AS mrn, var__hospital_code AS hospital_code, var__case_no AS case_no, var__case_type AS case_type, var__admission_dtm AS admission_dtm, var__discharge_code AS discharge_code, var__discharge_dtm AS discharge_dtm, var__destination_code AS destination_code, var__last_specialty AS last_specialty, var__last_sub_specialty AS last_sub_specialty, var__last_ward_code AS last_ward_code, var__last_ward_class AS last_ward_class, var__last_bed_no AS last_bed_no, var__status_code AS status_code, var__hcrs_patient_id AS hcrs_patient_id,
                /* Cheung on 30/10/97 */
                var__hcrs_case_no AS hcrs_case_no,
                /* Cheung on 30/10/97 */
                var__hp_update_dtm AS hp_update_dtm,
                /* Cheung on 30/10/97 */
                var__hc_update_dtm AS hc_update_dtm,
                /* Cheung on 30/10/97 */
                var__hp_sync_flag AS hp_sync_flag,
                /* Cheung on 30/10/97 */
                var__hp_reg_flag AS hp_reg_flag,
                /* Cheung on 30/10/97 */
                var__hc_sync_flag AS hc_sync_flag,
                /* Cheung on 30/10/97 */
                var__hc_reg_flag AS hc_reg_flag,
                /* Cheung on 30/10/97 */
                var__patient_class;
            /* Cheung on 17-Oct-1998 */
	return next p_refcur;
            RETURN;
        END;
    ELSE
        BEGIN
            IF OCTET_LENGTH(par_case_no) < 12 THEN
                BEGIN
                    SELECT
                        CONCAT(' ', par_case_no)
                        INTO par_case_no;
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
                    select
            			@patient_key patient_key ,null hkid ,null patient_name
            			,null sex ,null cccode1 ,null cccode2 ,null cccode3
            			,null cccode4 ,null cccode5 ,null cccode6
            			,null chi_name ,null dob ,null exact_dob_flag
            			,null home_phone ,null office_phone ,null other_phone
            			,null death_indicator
            			,null mrn
                        ,null hospital_code ,null case_no
            			,null case_type ,null admission_dtm ,null discharge_code
            			,null discharge_dtm ,null destination_code
            			,null last_specialty ,null last_sub_specialty
            			,null last_ward_code ,null last_ward_class ,null last_bed_no
            			,null status_code	/* Ronde LEUNG 27 Jun 1997 */
                    ** Ronde LEUNG 4 Aug 1997 (end)
            */
            OPEN p_refcur FOR
            SELECT
                var_patient_key AS patient_key, var__hkid AS hkid, var__patient_name AS patient_name, var__sex AS sex, var__cccode1 AS cccode1, var__cccode2 AS cccode2, var__cccode3 AS cccode3, var__cccode4 AS cccode4, var__cccode5 AS cccode5, var__cccode6 AS cccode6, var__chi_name AS chi_name, var__dob AS dob, var__exact_dob_flag AS exact_dob_flag, var__home_phone AS home_phone, var__office_phone AS office_phone, var__other_phone AS other_phone, var__death_indicator AS death_indicator, var_mrn AS mrn, var__hospital_code AS hospital_code, var__case_no AS case_no, var__case_type AS case_type, var__admission_dtm AS admission_dtm, var__discharge_code AS discharge_code, var__discharge_dtm AS discharge_dtm, var__destination_code AS destination_code, var__last_specialty AS last_specialty, var__last_sub_specialty AS last_sub_specialty, var__last_ward_code AS last_ward_code, var__last_ward_class AS last_ward_class, var__last_bed_no AS last_bed_no, var__status_code AS status_code, var__hcrs_patient_id AS hcrs_patient_id,
                /* Cheung on 30/10/97 */
                var__hcrs_case_no AS hcrs_case_no,
                /* Cheung on 30/10/97 */
                var__hp_update_dtm AS hp_update_dtm,
                /* Cheung on 30/10/97 */
                var__hc_update_dtm AS hc_update_dtm,
                /* Cheung on 30/10/97 */
                var__hp_sync_flag AS hp_sync_flag,
                /* Cheung on 30/10/97 */
                var__hp_reg_flag AS hp_reg_flag,
                /* Cheung on 30/10/97 */
                var__hc_sync_flag AS hc_sync_flag,
                /* Cheung on 30/10/97 */
                var__hc_reg_flag AS hc_reg_flag,
                /* Cheung on 30/10/97 */
                var__patient_class;
            /* Cheung on 17-Oct-1998 */
	return next p_refcur;
            RETURN;
        END;
    END IF;
    SELECT
        patient_key
        INTO var_patient_key
        FROM pmi_case
        WHERE case_no = par_case_no AND hospital_code = par_hospital_code;

    IF var_patient_key IS NULL OR LTRIM(RTRIM(var_patient_key)) IS NULL THEN
        BEGIN
            SELECT
                'mnulpkey'
                INTO var_patient_key;
            /*
            Ronde LEUNG 4 Aug 1997 (begin)
                    select
            			@patient_key patient_key ,null hkid ,null patient_name
            			,null sex ,null cccode1 ,null cccode2 ,null cccode3
            			,null cccode4 ,null cccode5 ,null cccode6
            			,null chi_name ,null dob ,null exact_dob_flag
            			,null home_phone ,null office_phone ,null other_phone
            			,null death_indicator
            			,null mrn
                        ,null hospital_code ,null case_no
            			,null case_type ,null admission_dtm ,null discharge_code
            			,null discharge_dtm ,null destination_code
            			,null last_specialty ,null last_sub_specialty
            			,null last_ward_code ,null last_ward_class ,null last_bed_no
            			,null status_code	/* Ronde LEUNG 27 Jun 1997 */
                    ** Ronde LEUNG 4 Aug 1997 (end)
            */
            OPEN p_refcur FOR
            SELECT
                var_patient_key AS patient_key, var__hkid AS hkid, var__patient_name AS patient_name, var__sex AS sex, var__cccode1 AS cccode1, var__cccode2 AS cccode2, var__cccode3 AS cccode3, var__cccode4 AS cccode4, var__cccode5 AS cccode5, var__cccode6 AS cccode6, var__chi_name AS chi_name, var__dob AS dob, var__exact_dob_flag AS exact_dob_flag, var__home_phone AS home_phone, var__office_phone AS office_phone, var__other_phone AS other_phone, var__death_indicator AS death_indicator, var_mrn AS mrn, var__hospital_code AS hospital_code, var__case_no AS case_no, var__case_type AS case_type, var__admission_dtm AS admission_dtm, var__discharge_code AS discharge_code, var__discharge_dtm AS discharge_dtm, var__destination_code AS destination_code, var__last_specialty AS last_specialty, var__last_sub_specialty AS last_sub_specialty, var__last_ward_code AS last_ward_code, var__last_ward_class AS last_ward_class, var__last_bed_no AS last_bed_no, var__status_code AS status_code, var__hcrs_patient_id AS hcrs_patient_id,
                /* Cheung on 30/10/97 */
                var__hcrs_case_no AS hcrs_case_no,
                /* Cheung on 30/10/97 */
                var__hp_update_dtm AS hp_update_dtm,
                /* Cheung on 30/10/97 */
                var__hc_update_dtm AS hc_update_dtm,
                /* Cheung on 30/10/97 */
                var__hp_sync_flag AS hp_sync_flag,
                /* Cheung on 30/10/97 */
                var__hp_reg_flag AS hp_reg_flag,
                /* Cheung on 30/10/97 */
                var__hc_sync_flag AS hc_sync_flag,
                /* Cheung on 30/10/97 */
                var__hc_reg_flag AS hc_reg_flag,
                /* Cheung on 30/10/97 */
                var__patient_class;
            /* Cheung on 17-Oct-1998 */
	return next p_refcur;
            RETURN;
        END;
    END IF;

    IF par_hospital_code = 'UCH' THEN
        BEGIN
            SELECT
                mrn
                INTO var_mrn
                FROM patient_hospital_data
                WHERE patient_key = var_patient_key AND hospital_code = par_hospital_code;

            IF var_mrn IS NULL OR LTRIM(RTRIM(var_mrn)) IS NULL THEN
                BEGIN
                    /*
                    Cheung on 12-Jul-1999 (begin)
                    **	select @patient_key = 'mnulmrn'
                    ** Cheung on 12-Jul-1999 (end)
                    */
                    /*
                    Ronde LEUNG 4 Aug 1997 (begin)
                    			select
                    				@patient_key patient_key ,null hkid ,null patient_name
                    				,null sex ,null cccode1 ,null cccode2 ,null cccode3
                    				,null cccode4 ,null cccode5 ,null cccode6
                    				,null chi_name ,null dob ,null exact_dob_flag
                    				,null home_phone ,null office_phone ,null other_phone
                    				,null death_indicator
                    				,null mrn
                    				,null hospital_code ,null case_no
                    				,null case_type ,null admission_dtm ,null discharge_code
                    				,null discharge_dtm ,null destination_code
                    				,null last_specialty ,null last_sub_specialty
                    				,null last_ward_code ,null last_ward_class ,null last_bed_no
                    				,null status_code	/* Ronde LEUNG 27 Jun 1997 */
                            ** Ronde LEUNG 4 Aug 1997 (end)
                    */
                    /*
                    Cheung on 12-Jul-1999 (begin)
                    	select
                    		@patient_key patient_key, @_hkid hkid
                    		,@_patient_name patient_name ,@_sex sex
                    		,@_cccode1 cccode1 ,@_cccode2 cccode2 ,@_cccode3 cccode3
                    		,@_cccode4 cccode4 ,@_cccode5 cccode5 ,@_cccode6 cccode6
                    		,@_chi_name chi_name ,@_dob dob
                    		,@_exact_dob_flag exact_dob_flag ,@_home_phone home_phone
                    		,@_office_phone office_phone ,@_other_phone other_phone
                    		,@_death_indicator death_indicator
                    		,@mrn mrn
                    		,@_hospital_code hospital_code ,@_case_no case_no
                    		,@_case_type case_type ,@_admission_dtm admission_dtm
                    		,@_discharge_code discharge_code ,@_discharge_dtm discharge_dtm
                    		,@_destination_code destination_code
                    		,@_last_specialty last_specialty
                    		,@_last_sub_specialty last_sub_specialty
                    		,@_last_ward_code last_ward_code ,@_last_ward_class last_ward_class
                    		,@_last_bed_no last_bed_no ,@_status_code status_code
                    		,@_hcrs_patient_id hcrs_patient_id	-- Cheung on 30/10/97
                    		,@_hcrs_case_no hcrs_case_no		-- Cheung on 30/10/97
                    		,@_hp_update_dtm hp_update_dtm		-- Cheung on 30/10/97
                    		,@_hc_update_dtm hc_update_dtm		-- Cheung on 30/10/97
                    		,@_hp_sync_flag hp_sync_flag		-- Cheung on 30/10/97
                    		,@_hp_reg_flag hp_reg_flag			-- Cheung on 30/10/97
                    		,@_hc_sync_flag hc_sync_flag		-- Cheung on 30/10/97
                    		,@_hc_reg_flag hc_reg_flag			-- Cheung on 30/10/97
                    		,@_patient_class					-- Cheung on 17-Oct-1998
                    
                    	return
                    ** Cheung on 12-Jul-1999 (end)
                    */
                    SELECT
                        REPEAT(' ', 8)
                        INTO var_mrn
                    /* Cheung on 12-Jul-1999 */
                    ;
                END;
            ELSE
                /* whkwok on 18/6/97 */
                BEGIN
                    SELECT
                        LTRIM(RTRIM(var_mrn))
                        INTO var_mrn;
                END;
            END IF;
        END;
    ELSE
        BEGIN
            SELECT
                REPEAT(' ', 8)
                INTO var_mrn;
        END;
    END IF;
    OPEN p_refcur FOR
    /* --		@patient_key patient_key		-- whkwok on 18/6/97 */
    SELECT
        p.patient_key,
        /* Cheung on 17-Oct-1998 */
        LTRIM(p.hkid) AS hkid, p.patient_name, p.sex, p.cccode1, p.cccode2, p.cccode3, p.cccode4, p.cccode5, p.cccode6, p.chi_name, p.dob, p.exact_dob_flag, 
        p.phone1, 
        CASE WHEN p.phone2 IS NULL AND p.address_indicator IS NULL THEN NULL
        ELSE CONCAT(p.phone2, p.address_indicator) END AS office_phone,
        CASE WHEN p.mobile_phone IS NULL AND p.sms_language IS NULL THEN NULL
        ELSE CONCAT(p.mobile_phone, p.sms_language) END AS other_phone, 
        p.death_indicator, var_mrn AS mrn, c.hospital_code, LTRIM(c.case_no) AS case_no, c.case_type, c.adm_dtm, c.discharge_code, c.discharge_dtm, c.destination_code,
        /* Lapres on 12-Apr-06 SCR:1838 (Begin) */
        
        /* --,c.adm_specialty_code ,c.last_specialty_code */
        c.last_specialty_code, '',
        /* sub specialty code not support in MPI */
        /* Lapres on 12-Apr-06 SCR:1838 (End) */
        c.last_ward_code, c.last_ward_class, c.last_bed_no, 'AC' AS status_code, /* Ronde LEUNG 27 Jun 1997 */ var__hcrs_patient_id AS hcrs_patient_id,
        /* Cheung on 30/10/97 */
        var__hcrs_case_no AS hcrs_case_no,
        /* Cheung on 30/10/97 */
        var__hp_update_dtm AS hp_update_dtm,
        /* Cheung on 30/10/97 */
        var__hc_update_dtm AS hc_update_dtm,
        /* Cheung on 30/10/97 */
        var__hp_sync_flag AS hp_sync_flag,
        /* Cheung on 30/10/97 */
        var__hp_reg_flag AS hp_reg_flag,
        /* Cheung on 30/10/97 */
        var__hc_sync_flag AS hc_sync_flag,
        /* Cheung on 30/10/97 */
        var__hc_reg_flag AS hc_reg_flag,
        /* Cheung on 30/10/97 */
        CAST ((~ CAST (CASE
            WHEN (p.access_code & 1) < 0 OR (p.access_code & 1) > 0 THEN 1
            WHEN (p.access_code & 1) = 0 THEN 0
        END AS NUMERIC(1, 0))::INT::BIT(1))::INT::NUMERIC(1, 0) AS SMALLINT) AS patient_class
        /* Cheung on 17-Oct-1998 */
        FROM pmi_case AS c, patient AS p
        WHERE c.patient_key = var_patient_key AND c.case_no = par_case_no AND c.hospital_code = par_hospital_code AND p.patient_key = var_patient_key;
	return next p_refcur;
END;
/* Remarked by Cheung on 29/12/1997 (begin) */

/* --and		not ((c.case_type = "A" or c.case_type = "I" or c.case_type = "D") */

/* --and		c.discharge_dtm <> null) */
/* Remarked by Cheung on 29/12/1997 (end) */
$function$
;


ALTER FUNCTION "hcrspq_gethkpmi_episode" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

