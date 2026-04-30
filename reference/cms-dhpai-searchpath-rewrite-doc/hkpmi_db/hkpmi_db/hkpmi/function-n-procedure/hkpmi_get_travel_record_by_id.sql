-- DROP FUNCTION hkpmi.hkpmi_get_travel_record_by_id(varchar);

CREATE OR REPLACE FUNCTION hkpmi.hkpmi_get_travel_record_by_id(par_hkid character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
    var_patient_key VARCHAR(16);
    var_source_system VARCHAR(10);
    var_travel_indicator VARCHAR(10);
    var_control_point VARCHAR(200);
    var_travel_type VARCHAR(10);
    var_checking_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_reply_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_entry_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_depart_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_update_datetime TIMESTAMP WITHOUT TIME ZONE;
    p_refcur refcursor;
BEGIN
    SELECT
        patient_key
        INTO var_patient_key
        FROM patient
        WHERE hkid = par_hkid;
    SELECT
        t.source_system, t.travel_indicator, t.reply_datetime, t.control_point, t.travel_type, t.entry_datetime, t.update_datetime
        INTO var_source_system, var_travel_indicator, var_reply_datetime, var_control_point, var_travel_type, var_entry_datetime, var_update_datetime
        FROM hkpmi_patient_travel_record AS t, patient AS p
        WHERE t.patient_key = p.patient_key AND t.patient_key = var_patient_key;
    /* --and p.hkid = @hkid */
    IF var_travel_indicator = 'N' THEN
        BEGIN
            SELECT
                'NO'
                INTO var_travel_indicator;
            SELECT
                NULL
                INTO var_entry_datetime;
            SELECT
                var_reply_datetime
                INTO var_checking_datetime;
            SELECT
                - 30 * INTERVAL '1 day' + to_timestamp(var_reply_datetime::TEXT,'YYYY-MM-DD HH24:MI:SS')::TIMESTAMP
                INTO var_reply_datetime;
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
                    NULL
                    INTO var_reply_datetime;

                IF var_travel_type = 'OUT' OR var_travel_type = 'D' THEN
                    BEGIN
                        SELECT
                            var_entry_datetime
                            INTO var_depart_datetime;
                        SELECT
                            NULL
                            INTO var_entry_datetime;
                        SELECT
                            'OUT'
                            INTO var_travel_type;
                    END;
                ELSE
                    SELECT
                        'IN'
                        INTO var_travel_type;
                END IF;
            END;
        ELSE
            SELECT
                'UNKNOWN'
                INTO var_travel_indicator;
        END IF;
    END IF;
    SELECT
        eng_desc
        INTO var_control_point
        FROM control_point_code_table
        WHERE code = var_control_point;
    OPEN p_refcur FOR
    SELECT
        var_patient_key AS patient_key, var_travel_indicator AS travel_indicator, var_control_point AS control_point, var_travel_type AS travel_type, var_checking_datetime AS checking_datetime, var_reply_datetime AS notravelhistorysince, var_entry_datetime AS entry_datetime, var_depart_datetime AS depart_datetime, var_update_datetime AS update_datetime;
		return next p_refcur;
END;
$function$
;


ALTER FUNCTION "hkpmi_get_travel_record_by_id" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
