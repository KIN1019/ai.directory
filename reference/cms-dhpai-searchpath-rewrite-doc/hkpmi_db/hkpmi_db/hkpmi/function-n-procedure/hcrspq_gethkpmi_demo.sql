-- DROP FUNCTION hkpmi.hcrspq_gethkpmi_demo(varchar, varchar);

CREATE OR REPLACE FUNCTION hkpmi.hcrspq_gethkpmi_demo(par_hkid character varying, par_hospital_code character varying)
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
    var__hcrs_patient_id VARCHAR(16);
    var__update_dtm TIMESTAMP WITHOUT TIME ZONE;
    /* Ronde LEUNG 4 Aug 1997 (end) */
    var__sync_flag VARCHAR(1);
    /* Cheung on 24/10/97 */
    var__reg_flag VARCHAR(1);
    /* Cheung on 24/10/97 */
    var__patient_class SMALLINT;
BEGIN
    /* Cheung on 17-Oct-1998 */
    SELECT
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
        /* Cheung on 30/10/97 */
        NULL,
        /* Cheung on 30/10/97 */
        NULL
        INTO var_patient_key, var_mrn, var__hkid, var__patient_name, var__sex, var__cccode1, var__cccode2, var__cccode3, var__cccode4, var__cccode5, var__cccode6, var__chi_name, var__dob, var__exact_dob_flag, var__home_phone, var__office_phone, var__other_phone, var__death_indicator, var__hcrs_patient_id, var__update_dtm, var__sync_flag, var__reg_flag, var__patient_class;
    /* Cheung on 17-Oct-1998 */
    /* Cheung, start on 19/6/97 */
    /* Trim all input arguments */
    SELECT
        LTRIM(RTRIM(par_hkid)), LTRIM(RTRIM(par_hospital_code))
        INTO par_hkid, par_hospital_code;
    /* end on 19/6/97 */

    IF par_hkid IS NULL THEN
        BEGIN
            SELECT
                'mnulhkid'
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
            ** Ronde LEUNG 4 Aug 1997 (end)
            */
            OPEN p_refcur FOR
            SELECT
                var_patient_key AS patient_key, var__hkid AS hkid, var__patient_name AS patient_name, var__sex AS sex, var__cccode1 AS cccode1, var__cccode2 AS cccode2, var__cccode3 AS cccode3, var__cccode4 AS cccode4, var__cccode5 AS cccode5, var__cccode6 AS cccode6, var__chi_name AS chi_name, var__dob AS dob, var__exact_dob_flag AS exact_dob_flag, var__home_phone AS home_phone, var__office_phone AS office_phone, var__other_phone AS other_phone, var__death_indicator AS death_indicator, var_mrn AS mrn, var__hcrs_patient_id AS hcrs_patient_id,
                /* Cheung on 30/10/97 */
                var__update_dtm AS update_dtm,
                /* Cheung on 30/10/97 */
                var__sync_flag AS sync_flag, var__reg_flag AS reg_flag,
                /* Cheung on 30/10/97 */
                var__patient_class;
            /* Cheung on 17-Oct-1998 */
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
            select
            	@patient_key patient_key ,null hkid ,null patient_name
            	,null sex ,null cccode1 ,null cccode2 ,null cccode3
            	,null cccode4 ,null cccode5 ,null cccode6
            	,null chi_name ,null dob ,null exact_dob_flag
            	,null home_phone ,null office_phone ,null other_phone
            	,null death_indicator
            	,null mrn
            ** Ronde LEUNG 4 Aug 1997 (end)
            */
            OPEN p_refcur FOR
            SELECT
                var_patient_key AS patient_key, var__hkid AS hkid, var__patient_name AS patient_name, var__sex AS sex, var__cccode1 AS cccode1, var__cccode2 AS cccode2, var__cccode3 AS cccode3, var__cccode4 AS cccode4, var__cccode5 AS cccode5, var__cccode6 AS cccode6, var__chi_name AS chi_name, var__dob AS dob, var__exact_dob_flag AS exact_dob_flag, var__home_phone AS home_phone, var__office_phone AS office_phone, var__other_phone AS other_phone, var__death_indicator AS death_indicator, var_mrn AS mrn, var__hcrs_patient_id AS hcrs_patient_id,
                /* Cheung on 30/10/97 */
                var__update_dtm AS update_dtm,
                /* Cheung on 30/10/97 */
                var__sync_flag AS sync_flag, var__reg_flag AS reg_flag,
                /* Cheung on 30/10/97 */
                var__patient_class;
            /* Cheung on 17-Oct-1998 */
			return next p_refcur;
            RETURN;
        END;
    END IF;

    IF par_hospital_code = 'UCH' THEN
        BEGIN
            /* whkwok on 3/7/97 */
            /* added here for performance sake */
            
            /* -- */
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
                    select
                    	@patient_key patient_key ,null hkid ,null patient_name
                    	,null sex ,null cccode1 ,null cccode2 ,null cccode3
                    	,null cccode4 ,null cccode5 ,null cccode6
                    	,null chi_name ,null dob ,null exact_dob_flag
                    	,null home_phone ,null office_phone ,null other_phone
                    	,null death_indicator
                    	,null mrn
                    ** Ronde LEUNG 4 Aug 1997 (end)
                    */
                    OPEN p_refcur FOR
                    SELECT
                        var_patient_key AS patient_key, var__hkid AS hkid, var__patient_name AS patient_name, var__sex AS sex, var__cccode1 AS cccode1, var__cccode2 AS cccode2, var__cccode3 AS cccode3, var__cccode4 AS cccode4, var__cccode5 AS cccode5, var__cccode6 AS cccode6, var__chi_name AS chi_name, var__dob AS dob, var__exact_dob_flag AS exact_dob_flag, var__home_phone AS home_phone, var__office_phone AS office_phone, var__other_phone AS other_phone, var__death_indicator AS death_indicator, var_mrn AS mrn, var__hcrs_patient_id AS hcrs_patient_id,
                        /* Cheung on 30/10/97 */
                        var__update_dtm AS update_dtm,
                        /* Cheung on 30/10/97 */
                        var__sync_flag AS sync_flag, var__reg_flag AS reg_flag,
                        /* Cheung on 30/10/97 */
                        var__patient_class;
                    /* Cheung on 17-Oct-1998 */
			return next p_refcur;
                    RETURN;
                END;
            END IF;
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
                    		,@_hcrs_patient_id hcrs_patient_id				-- Cheung on 30/10/97
                    		,@_update_dtm update_dtm						-- Cheung on 30/10/97
                    		,@_sync_flag sync_flag, @_reg_flag reg_flag		-- Cheung on 30/10/97
                    		,@_patient_class								-- Cheung on 17-Oct-1998
                    
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
    SELECT
        p.patient_key,
        /* whkwok on 03/7/97 */
        LTRIM(p.hkid) AS hkid,
        /* whkwok on 18/6/97 */
        p.patient_name, p.sex, p.cccode1, p.cccode2, p.cccode3, p.cccode4, p.cccode5, p.cccode6, p.chi_name, p.dob, p.exact_dob_flag, p.phone1,
        /* whkwok on 18/6/97 */
        CASE WHEN p.phone2 IS NULL AND p.address_indicator IS NULL THEN NULL
        ELSE CONCAT(p.phone2, p.address_indicator) END AS office_phone,
        /* whkwok on 18/6/97 */
        CASE WHEN p.mobile_phone IS NULL AND p.sms_language IS NULL THEN NULL
        ELSE CONCAT(p.mobile_phone, p.sms_language) END AS other_phone, 
        CASE WHEN p.death_indicator IS NULL THEN 'N' ELSE 'Y' END AS death_indicator, 
        var_mrn AS mrn,
        /* whkwok on 18/6/97 */
        var__hcrs_patient_id AS hcrs_patient_id,
        /* Cheung on 30/10/97 */
        var__update_dtm AS update_dtm,
        /* Cheugn on 30/10/97 */
        var__sync_flag AS sync_flag,
        /* Cheung on 30/10/97 */
        var__reg_flag AS reg_flag,
        /* Cheung on 30/10/97 */
        CAST ((~ CAST (CASE
            WHEN (p.access_code & 1) < 0 OR (p.access_code & 1) > 0 THEN 1
            WHEN (p.access_code & 1) = 0 THEN 0
        END AS NUMERIC(1, 0))::INT::BIT(1))::INT::NUMERIC(1, 0) AS SMALLINT) AS patient_class
        /* Cheung on 17-Oct-1998 */
        FROM patient AS p
        WHERE p.hkid = par_hkid;
			return next p_refcur;
END;
$function$
;


ALTER FUNCTION "hcrspq_gethkpmi_demo" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

