-- DROP FUNCTION hkpmi.hkpmi_get_travel_record(varchar, varchar);

CREATE OR REPLACE FUNCTION hkpmi.hkpmi_get_travel_record(par_hkid character varying, par_patient_key character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
declare p_refcur refcursor;
DECLARE
    var_language_code VARCHAR(5);
    var_language VARCHAR(50);
    var_lang_status VARCHAR(5);
    var_lang_source_system VARCHAR(5);
    var_lang_update_hospital VARCHAR(3);
    var_lang_update_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_lang_update_by VARCHAR(12);
    /* ---------- Patient Travel History ---------- */
    var_source_system VARCHAR(5);
    var_travel_indicator VARCHAR(10);
    var_control_point VARCHAR(200);
    var_travel_type VARCHAR(10);
    var_checking_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_reply_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_entry_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_depart_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_update_datetime TIMESTAMP WITHOUT TIME ZONE;
    "var_travelDateDiff" INTEGER;
    "var_travelMessage1" VARCHAR(120);
    "var_travelMessage2" VARCHAR(100);
    "var_iconColor" VARCHAR(10);
    var_checking_datetime_format VARCHAR(30);
    var_reply_datetime_format VARCHAR(20);
    var_entry_datetime_format VARCHAR(20);
    var_depart_datetime_format VARCHAR(20);
BEGIN
    SELECT
        0
        INTO "var_travelDateDiff";
    SELECT
        'Travel history cannot be confirmed with Immigration Department. Please check travel history with patient.'
        INTO "var_travelMessage1";
    SELECT
        NULL
        INTO "var_travelMessage2";
    SELECT
        'Grey'
        INTO "var_iconColor";
    SELECT
        t.source_system, t.travel_indicator, t.reply_datetime, t.control_point, t.travel_type, t.entry_datetime, t.update_datetime
        INTO var_source_system, var_travel_indicator, var_reply_datetime, var_control_point, var_travel_type, var_entry_datetime, var_update_datetime
        FROM hkpmi_patient_travel_record AS t, patient AS p
        WHERE t.patient_key = p.patient_key AND t.patient_key = par_patient_key AND p.hkid = par_hkid;
    SELECT
        eng_desc
        INTO var_control_point
        FROM control_point_code_table
        WHERE code = var_control_point;
    /*
    [3014 - Severity CRITICAL - PostgreSQL doesn't support the CONVERT function. Use suitable function or create user defined function.]
    select @entry_datetime_format = str_replace(CONVERT(NVARCHAR,@entry_datetime, 106), ' ', '-')
    */
    SELECT
                      TO_CHAR(var_entry_datetime, 'DD-Mon-YYYY')
                      INTO var_entry_datetime_format;  
    IF DATE_PART('days', timestamp_convert(localtimestamp)::TIMESTAMP - var_reply_datetime::TIMESTAMP) >= 7 THEN
        BEGIN
            SELECT
                'UNKNOWN'
                INTO var_travel_indicator;
            SELECT
                NULL
                INTO var_source_system;
            SELECT
                NULL
                INTO var_reply_datetime;
            SELECT
                NULL
                INTO var_control_point;
            SELECT
                NULL
                INTO var_travel_type;
            SELECT
                NULL
                INTO var_entry_datetime_format;
            SELECT
                NULL
                INTO var_update_datetime;
        END;
    ELSE
        IF var_travel_indicator = 'N' THEN
            BEGIN
                SELECT
                    'NO'
                    INTO var_travel_indicator;
                SELECT
                    NULL
                    INTO var_entry_datetime;
                SELECT
                    NULL
                    INTO var_entry_datetime_format;
                SELECT
                    var_reply_datetime
                    INTO var_checking_datetime;
                /*
                [3014 - Severity CRITICAL - PostgreSQL doesn't support the CONVERT function. Use suitable function or create user defined function., 3014 - Severity CRITICAL - PostgreSQL doesn't support the CONVERT function. Use suitable function or create user defined function.]
                select @checking_datetime_format = str_replace(CONVERT(NVARCHAR,@checking_datetime, 105), ' ', '-') + ' ' +CONVERT(NVARCHAR,@checking_datetime, 108)
                */
                 SELECT
                                TO_CHAR(var_checking_datetime, 'DD-MM-YYYY HH24:mi:ss')
                                INTO var_checking_datetime_format;  
                SELECT
                    - 30 * INTERVAL '1 day' + var_reply_datetime::TIMESTAMP
                    INTO var_reply_datetime;
                /*
                [3014 - Severity CRITICAL - PostgreSQL doesn't support the CONVERT function. Use suitable function or create user defined function.]
                select @reply_datetime_format = str_replace(CONVERT(NVARCHAR,@reply_datetime, 106), ' ', '-')
                */
                SELECT
                      TO_CHAR(var_reply_datetime, 'DD-Mon-YYYY')
                      INTO var_reply_datetime_format; 
            END;
        ELSE
            IF var_travel_indicator = 'Y' THEN
                BEGIN
                    SELECT
                        'YES'
                        INTO var_travel_indicator;
                    SELECT
                        var_reply_datetime
                        INTO var_checking_datetime;
                    /*
                    [3014 - Severity CRITICAL - PostgreSQL doesn't support the CONVERT function. Use suitable function or create user defined function., 3014 - Severity CRITICAL - PostgreSQL doesn't support the CONVERT function. Use suitable function or create user defined function.]
                    select @checking_datetime_format = str_replace(CONVERT(NVARCHAR,@checking_datetime, 105), ' ', '-') + ' ' +CONVERT(NVARCHAR,@checking_datetime, 108)
                    */
                    SELECT
                                TO_CHAR(var_checking_datetime, 'DD-MM-YYYY HH24:mi:ss')
                                INTO var_checking_datetime_format;  
                    SELECT
                        NULL
                        INTO var_reply_datetime;
                    SELECT
                        NULL
                        INTO var_reply_datetime_format;
                    SELECT
                        DATE_PART('days', timestamp_convert(localtimestamp)::TIMESTAMP - var_entry_datetime::TIMESTAMP)
                        INTO "var_travelDateDiff";

                    IF var_travel_type = 'OUT' OR var_travel_type = 'D' THEN
                        BEGIN
                            SELECT
                                var_entry_datetime
                                INTO var_depart_datetime;
                            /*
                            [3014 - Severity CRITICAL - PostgreSQL doesn't support the CONVERT function. Use suitable function or create user defined function.]
                            select @depart_datetime_format = str_replace(CONVERT(NVARCHAR,@depart_datetime, 106), ' ', '-')
                            */
                             SELECT
                                TO_CHAR(var_depart_datetime, 'DD-Mon-YYYY')
                                INTO var_depart_datetime_format;
                            SELECT
                                NULL
                                INTO var_entry_datetime;
                            SELECT
                                NULL
                                INTO var_entry_datetime_format;
                            SELECT
                                'OUT'
                                INTO var_travel_type;

                            IF "var_travelDateDiff" <= 30 THEN
                                BEGIN
                                    IF "var_travelDateDiff" = 0 THEN
                                        SELECT
                                            CONCAT('Patient left Hong Kong today (', var_depart_datetime_format, ') via ', var_control_point, '.')
                                            INTO "var_travelMessage1";
                                    ELSE
                                        SELECT
                                            CONCAT('Patient left Hong Kong ',
                                            CASE CAST ("var_travelDateDiff" AS VARCHAR(3))
                                                WHEN '' THEN ''
                                                ELSE CAST ("var_travelDateDiff" AS VARCHAR(3))
                                            END, ' day(s) ago (', var_depart_datetime_format, ') via ', var_control_point, '.')
                                            INTO "var_travelMessage1";
                                    END IF;
                                    SELECT
                                        'Red'
                                        INTO "var_iconColor";
                                    /*
                                    [3014 - Severity CRITICAL - PostgreSQL doesn't support the CONVERT function. Use suitable function or create user defined function.]
                                    select @travelMessage2 ='Source: Immigration Department (as of ' + str_replace(CONVERT(NVARCHAR,@checking_datetime, 106), ' ', '-') + ')'
                                    */
                                    SELECT
                                                    CONCAT('Source: Immigration Department (as of ', TO_CHAR(var_checking_datetime, 'DD-Mon-YYYY'), ')')
                                                    INTO "var_travelMessage2";
                                END;
                            END IF;
                        END;
                    ELSE
                        BEGIN
                            SELECT
                                'IN'
                                INTO var_travel_type;

                            IF "var_travelDateDiff" <= 30 THEN
                                BEGIN
                                    IF "var_travelDateDiff" = 0 THEN
                                        SELECT
                                            CONCAT('Patient entered Hong Kong today (', var_entry_datetime_format, ') via ', var_control_point, '.')
                                            INTO "var_travelMessage1";
                                    ELSE
                                        SELECT
                                            CONCAT('Patient entered Hong Kong ',
                                            CASE CAST ("var_travelDateDiff" AS VARCHAR(3))
                                                WHEN '' THEN ''
                                                ELSE CAST ("var_travelDateDiff" AS VARCHAR(3))
                                            END, ' day(s) ago (', var_entry_datetime_format, ') via ', var_control_point, '.')
                                            INTO "var_travelMessage1";
                                    END IF;
                                    /*
                                    [3014 - Severity CRITICAL - PostgreSQL doesn't support the CONVERT function. Use suitable function or create user defined function.]
                                    select @travelMessage2 ='Source: Immigration Department (as of ' + str_replace(CONVERT(NVARCHAR,@checking_datetime, 106), ' ', '-') + ')'
                                    */
                                    SELECT
                                                    CONCAT('Source: Immigration Department (as of ', TO_CHAR(var_checking_datetime, 'DD-Mon-YYYY'), ')')
                                                    INTO "var_travelMessage2";
                                    IF "var_travelDateDiff" > 13 THEN
                                        SELECT
                                            'Amber'
                                            INTO "var_iconColor";
                                    ELSE
                                        SELECT
                                            'Red'
                                            INTO "var_iconColor";
                                    END IF;
                                END;
                            END IF;
                        END;
                    END IF;
                END;
            ELSE
                SELECT
                    'UNKNOWN'
                    INTO var_travel_indicator;
            END IF;
        END IF;
    END IF;
    SELECT
        l.language_code, i.language, l.status, l.source_system, l.update_hospital, l.update_datetime, l.update_by
        INTO var_language_code, var_language, var_lang_status, var_lang_source_system, var_lang_update_hospital, var_lang_update_datetime, var_lang_update_by
        FROM hkpmi_patient_language AS l, patient AS p, interpretation_language AS i
        WHERE l.patient_key = par_patient_key AND p.hkid = par_hkid AND l.patient_key = p.patient_key AND l.language_code = i.language_code AND l.status = 'A';
    OPEN p_refcur FOR
    SELECT
        par_hkid AS hkid, par_patient_key AS patient_key, var_language_code AS language_code, var_language AS language, var_lang_status AS lang_status, var_lang_source_system AS lang_source_system, var_lang_update_hospital AS lang_update_hospital, var_lang_update_datetime AS lang_update_datetime, var_lang_update_by AS lang_update_by, var_source_system AS source_system, var_travel_indicator AS travel_indicator, var_control_point AS control_point, var_travel_type AS travel_type, var_reply_datetime AS notravelhistorysince, var_entry_datetime AS entry_datetime, var_depart_datetime AS depart_datetime, var_update_datetime AS update_datetime, var_checking_datetime AS checking_datetime, "var_travelMessage1" AS travelmessage1, "var_travelMessage2" AS travelmessage2, "var_iconColor" AS iconcolor, var_reply_datetime_format AS reply_datetime_format, var_entry_datetime_format AS entry_datetime_format, var_depart_datetime_format AS depart_datetime_format, var_checking_datetime_format AS checking_datetime_format;
		return next p_refcur;
END;
$function$
;


ALTER FUNCTION "hkpmi_get_travel_record" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
