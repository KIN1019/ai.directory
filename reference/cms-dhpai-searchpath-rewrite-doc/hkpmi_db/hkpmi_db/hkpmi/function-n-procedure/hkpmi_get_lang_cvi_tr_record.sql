-- DROP FUNCTION hkpmi.hkpmi_get_lang_cvi_tr_record(varchar, varchar, varchar, varchar, varchar);

CREATE OR REPLACE FUNCTION hkpmi.hkpmi_get_lang_cvi_tr_record(par_hkid character varying, par_patient_key character varying, par_lang_enable character varying, par_travel_enable character varying, par_cvi_enable character varying)
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
    /* ---------- CVI record ---------- */
    "var_covidVacIndicator" VARCHAR(10);
    "var_covidVacStatus" VARCHAR(10);
    "var_cviMessage" VARCHAR(255);
    "var_sourceMessage" VARCHAR(255);
    var_cvi_control_value VARCHAR(100);
    "var_maxDoseMsg" INTEGER;
    "var_hideMsg" VARCHAR(1);
    "var_cviMsgMore" VARCHAR(1);
    "var_cviCheckDatetime" VARCHAR(20);
    var_row_count INTEGER;
    "var_tempMsg_1" VARCHAR(255);
    "var_tempMsg_2" VARCHAR(255);
    "var_forMoreMsg" VARCHAR(255);
    "var_msgMaxLength" INTEGER;
    var_v_source_system VARCHAR(5);
    var_v_vac_record_key VARCHAR(120);
    var_v_status VARCHAR(20);
    var_v_last_vaccine_brand VARCHAR(50);
    var_v_last_check_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_v_create_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_v_update_datetime TIMESTAMP WITHOUT TIME ZONE;
    temp_dose_msg CURSOR FOR
    SELECT
        CONCAT(dose_order, ' ', vaccine_brand, ' on ', REPLACE(to_char(dose_date::TIMESTAMP WITHOUT TIME ZONE,'DD Mon YYYY'), ' ', '-'))
        FROM hkpmi_patient_cvi_dose_info
        WHERE patient_key = par_patient_key AND update_datetime >= var_v_update_datetime
        ORDER BY dose_date DESC NULLS FIRST, vaccine_brand NULLS FIRST, dose_order DESC NULLS FIRST;
BEGIN
    IF par_travel_enable != 'N' THEN
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
           
            SELECT
                      TO_CHAR(var_entry_datetime, 'DD-Mon-YYYY')
                      INTO var_entry_datetime_format; 
            IF DATE_PART('days', localtimestamp::TIMESTAMP, var_reply_datetime::TIMESTAMP) >= 7 THEN
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
                       
                        SELECT
                                TO_CHAR(var_checking_datetime, 'DD-MM-YYYY') + ' ' +to_char(var_checking_datetime,'HH24:mi:ss')  
                                INTO var_checking_datetime_format;  
                        SELECT
                            - 30 * INTERVAL '1 day' + to_timestamp(var_reply_datetime::TEXT,'YYYY-MM-DD HH24:MI:SS')::TIMESTAMP
                            INTO var_reply_datetime;
                        
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
                            
                            SELECT
                                TO_CHAR(var_checking_datetime, 'DD-MM-YYYY') + ' ' +to_char(var_checking_datetime,'HH24:mi:ss')  
                                INTO var_checking_datetime_format;
                            SELECT
                                NULL
                                INTO var_reply_datetime;
                            SELECT
                                NULL
                                INTO var_reply_datetime_format;
                            SELECT
                                DATE_PART('days', localtimestamp::TIMESTAMP, var_entry_datetime::TIMESTAMP)
                                INTO "var_travelDateDiff";

                            IF var_travel_type = 'OUT' OR var_travel_type = 'D' THEN
                                BEGIN
                                    SELECT
                                        var_entry_datetime
                                        INTO var_depart_datetime;
                                    
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
                                           
                                            SELECT
                                                    'Source: Immigration Department (as of ' + TO_CHAR(var_checking_datetime, 'DD-Mon-YYYY') + ')'
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
                                           
                                            SELECT
                                                    'Source: Immigration Department (as of ' + TO_CHAR(var_checking_datetime, 'DD-Mon-YYYY') + ')'
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
        END;
    END IF;

    IF par_lang_enable != 'N' THEN
        BEGIN
            SELECT
                l.language_code, i.language, l.status, l.source_system, l.update_hospital, l.update_datetime, l.update_by
                INTO var_language_code, var_language, var_lang_status, var_lang_source_system, var_lang_update_hospital, var_lang_update_datetime, var_lang_update_by
                FROM hkpmi_patient_language AS l, patient AS p, interpretation_language AS i
                WHERE l.patient_key = par_patient_key AND p.hkid = par_hkid AND l.patient_key = p.patient_key AND l.language_code = i.language_code AND l.status = 'A';
        END;
    END IF;

    IF par_cvi_enable != 'N' THEN
        BEGIN
            /* Get covid19 vaccine record message */
            "var_maxDoseMsg" := 2;
            var_cvi_control_value := NULL;
            SELECT
                cvi_value
                INTO var_cvi_control_value
                FROM hkpmi_patient_cvi_control
                WHERE cvi_key = 'no_of_doses_tooltips_shown';

            IF (var_cvi_control_value IS NOT NULL AND var_cvi_control_value ~ '^[0-9]+$') THEN
                BEGIN
                    "var_maxDoseMsg" := CAST (var_cvi_control_value AS INTEGER);
                END;
            END IF;
            "var_hideMsg" := 'Y';
            var_cvi_control_value := NULL;
            SELECT
                cvi_value
                INTO var_cvi_control_value
                FROM hkpmi_patient_cvi_control
                WHERE cvi_key = 'enable_hidden_status';

            IF (var_cvi_control_value IS NOT NULL) THEN
                BEGIN
                    SELECT
                        var_cvi_control_value
                        INTO "var_hideMsg";
                END;
            END IF;
            SELECT
                source_system, vac_record_key, status, last_check_datetime, create_datetime, update_datetime
                INTO var_v_source_system, var_v_vac_record_key, var_v_status, var_v_last_check_datetime, var_v_create_datetime, var_v_update_datetime
                FROM hkpmi_patient_cvi_record
                WHERE patient_key = par_patient_key;
            SELECT
                msg_content
                INTO "var_sourceMessage"
                FROM hkpmi_patient_cvi_message
                WHERE msg_id = 'SOURCE';

            IF (var_v_status = 'VACCINATED' AND EXISTS (SELECT
                1
                FROM hkpmi_patient_cvi_dose_info
                WHERE patient_key = par_patient_key AND update_datetime >= var_v_update_datetime)) THEN
                BEGIN
                    "var_covidVacStatus" := 'YES';
                    SELECT
                        msg_content
                        INTO "var_cviMessage"
                        FROM hkpmi_patient_cvi_message
                        WHERE msg_id = "var_covidVacStatus";
                    "var_covidVacIndicator" := "var_covidVacStatus";
                    SELECT
                        COUNT(*)
                        INTO var_row_count
                        FROM hkpmi_patient_cvi_dose_info
                        WHERE patient_key = par_patient_key AND update_datetime >= var_v_update_datetime;
                    "var_cviMsgMore" := 'N';

                    IF var_row_count > "var_maxDoseMsg" THEN
                        BEGIN
                            "var_cviMsgMore" := 'Y';
                            SELECT
                                msg_content
                                INTO "var_forMoreMsg"
                                FROM hkpmi_patient_cvi_message
                                WHERE msg_id = 'FORMORE';

                            IF ("var_maxDoseMsg" = 0) THEN
                                "var_cviMessage" := "var_forMoreMsg";
                            END IF;
                        END;
                    END IF;
                    OPEN temp_dose_msg;
                    FETCH temp_dose_msg INTO "var_tempMsg_2";
                    "var_tempMsg_1" := "var_tempMsg_2";
                    "var_maxDoseMsg" := "var_maxDoseMsg" - 1;
                    FETCH temp_dose_msg INTO "var_tempMsg_2";

                    WHILE ((CASE FOUND::INT
                        WHEN 0 THEN - 1
                        ELSE 0
                    END) = 0 AND "var_maxDoseMsg" > 0) LOOP
                        "var_tempMsg_1" := CONCAT("var_tempMsg_1", ', ', "var_tempMsg_2");
                        "var_maxDoseMsg" := "var_maxDoseMsg" - 1;
                        FETCH temp_dose_msg INTO "var_tempMsg_2";
                    END LOOP;
                    "var_tempMsg_1" := CONCAT("var_tempMsg_1", '.', "var_forMoreMsg");
                    CLOSE temp_dose_msg;
                END;
            ELSE
                IF (var_v_status = 'NO_RECORD') THEN
                    BEGIN
                        "var_covidVacStatus" := 'NO';
                        SELECT
                            msg_content
                            INTO "var_cviMessage"
                            FROM hkpmi_patient_cvi_message
                            WHERE msg_id = "var_covidVacStatus";
                        "var_covidVacIndicator" := "var_covidVacStatus";

                        IF ("var_hideMsg" = 'Y') THEN
                            BEGIN
                                "var_covidVacIndicator" := 'HIDDEN';
                            END;
                        END IF;
                    END;
                ELSE
                    BEGIN
                        "var_covidVacStatus" := 'UNKNOWN';
                        SELECT
                            msg_content
                            INTO "var_cviMessage"
                            FROM hkpmi_patient_cvi_message
                            WHERE msg_id = "var_covidVacStatus";
                        "var_sourceMessage" := NULL;
                        "var_covidVacIndicator" := "var_covidVacStatus";

                        IF ("var_hideMsg" = 'Y') THEN
                            BEGIN
                                "var_covidVacIndicator" := 'HIDDEN';
                            END;
                        END IF;
                    END;
                END IF;
            END IF;
            "var_cviCheckDatetime" := REPLACE(to_char(var_v_last_check_datetime::TIMESTAMP WITHOUT TIME ZONE,'DD Mon YYYY'), ' ', '-');
            "var_sourceMessage" := REPLACE("var_sourceMessage", '<%source_dtm%>', "var_cviCheckDatetime");
            "var_cviCheckDatetime" := CONCAT("var_cviCheckDatetime", ' ', LEFT(to_char(var_v_last_check_datetime::TIMESTAMP WITHOUT TIME ZONE,'HH24:MI:SS'), 5));
            "var_cviCheckDatetime" := RTRIM("var_cviCheckDatetime");
            "var_cviMessage" := REPLACE("var_cviMessage", '<%DOSE_MSG%>', "var_tempMsg_1");
        END;
    END IF;
    OPEN p_refcur FOR
    SELECT
        par_hkid AS hkid, par_patient_key AS patient_key, var_language_code AS language_code, var_language AS language, var_lang_status AS lang_status, var_lang_source_system AS lang_source_system, var_lang_update_hospital AS lang_update_hospital, var_lang_update_datetime AS lang_update_datetime, var_lang_update_by AS lang_update_by, var_source_system AS source_system, var_travel_indicator AS travel_indicator, var_control_point AS control_point, var_travel_type AS travel_type, var_reply_datetime AS notravelhistorysince, var_entry_datetime AS entry_datetime, var_depart_datetime AS depart_datetime, var_update_datetime AS update_datetime, var_checking_datetime AS checking_datetime, "var_travelMessage1" AS travelmessage1, "var_travelMessage2" AS travelmessage2, "var_iconColor" AS iconcolor, var_reply_datetime_format AS reply_datetime_format, var_entry_datetime_format AS entry_datetime_format, var_depart_datetime_format AS depart_datetime_format, var_checking_datetime_format AS checking_datetime_format,
        /* ---------- CVI record ---------- */
        "var_covidVacIndicator" AS covidvacindicator, "var_cviMessage" AS cvimessage, "var_cviCheckDatetime" AS cvicheckdatetime, "var_sourceMessage" AS sourcemessage, "var_cviMsgMore" AS cvimsgmore, "var_covidVacStatus" AS covidvacstatus;
			return next p_refcur;
END;
$function$
;

ALTER FUNCTION "hkpmi_get_lang_cvi_tr_record" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
