-- DROP PROCEDURE hasp_get_link_exception(inout int4, in varchar, in timestamp, in timestamp, inout int4, inout refcursor);

CREATE OR REPLACE PROCEDURE hasp_get_link_exception(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_report_from_date timestamp without time zone, IN par_report_to_date timestamp without time zone, INOUT par_return_code integer, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_return INTEGER;
    var_case VARCHAR(12);
    var_adm_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_src_ind VARCHAR(1);
    var_src_code VARCHAR(5);
    var_ward VARCHAR(4);
    var_spec VARCHAR(4);
    var_hkid VARCHAR(12);
    var_prev_hosp VARCHAR(3);
    var_prev_case VARCHAR(12);
    var_server VARCHAR(30);
    var_hkpmi_down_flag VARCHAR(20);
    var_hkpmi_srvr TEXT;
    var_result VARCHAR(1);
    var_message VARCHAR(80);
    var_return_code int;
    var_rpc_call VARCHAR(60);
    dblink_sql TEXT;
    sql$rowcount BIGINT;
    csr CURSOR FOR
    SELECT
        case_no, previous_hospital, previous_case
        FROM Linked_case
        WHERE update_dtm >= par_report_from_date AND update_dtm < par_report_to_date AND hospital_code = par_hospital_code;
BEGIN
    SET search_path TO hpi, public; 

    SELECT
        'N'
        INTO var_hkpmi_down_flag;
    SELECT
        appl_ctl_text_value
        INTO var_hkpmi_down_flag
        FROM pas_appl_control
        WHERE hospital_code = par_hospital_code AND appl_name = 'IPAS' AND appl_ctl_type = 'HKPMI_SP1_DOWN';

    IF var_hkpmi_down_flag = 'Y' THEN
        BEGIN
            SELECT
                NULL
                INTO var_hkpmi_srvr;
            CALL cpi_get_rpc_server(pas_return_code, 'HKPMI_READ_ONLY_SVR', var_hkpmi_srvr);

            IF var_hkpmi_srvr IS NULL THEN
                BEGIN
                    pas_return_code := -1;
                    par_return_code := -1;
                    RETURN;
                END;
            END IF;
        END;
    END IF;

    DROP TABLE IF EXISTS t$temp_link;
    CREATE TEMPORARY TABLE t$temp_link
    (hkid VARCHAR(12),
        case_no VARCHAR(12),
        admission_datetime TIMESTAMP WITHOUT TIME ZONE,
        source_indicator VARCHAR(1) NULL,
        source_code VARCHAR(3) NULL,
        ward_code VARCHAR(4) NULL,
        specialty_code VARCHAR(4) NULL,
        previous_hospital VARCHAR(3),
        previous_case VARCHAR(12),
        return_message VARCHAR(80));
    CREATE UNIQUE INDEX temp_index ON t$temp_link
        (hkid, case_no, previous_hospital, previous_case);

    IF par_report_from_date IS NULL THEN
        IF par_report_to_date IS NULL THEN
            SELECT
                to_char(timestamp_convert(localtimestamp)- INTERVAL '1 day','YYYYMMDD')::timestamp
                INTO par_report_from_date;
        ELSE
            SELECT
                par_report_from_date
                INTO par_report_to_date;
        END IF;
    END IF;

    IF par_report_to_date IS NULL THEN
        SELECT
            1 * INTERVAL '1 day' + par_report_from_date::TIMESTAMP
            INTO par_report_to_date;
    ELSE
        SELECT
            1 * INTERVAL '1 day' + par_report_to_date::TIMESTAMP
            INTO par_report_to_date;
    END IF;
    OPEN csr;
    FETCH csr INTO var_case, var_prev_hosp, var_prev_case;

    WHILE (CASE
        WHEN FOUND THEN 0
        WHEN NOT FOUND THEN 2
        ELSE 1
    END) = 0 LOOP
        SELECT
            HKID, Admission_datetime, Source_indicator, Source_code
            INTO var_hkid, var_adm_dtm, var_src_ind, var_src_code
            FROM Case_view
            WHERE Case_no = var_case AND Hospital_code = par_hospital_code;

        /*--perform public.dblink_connect('PMI'::text, var_hkpmi_srvr);
        dblink_sql := 'call ' || /*var_rpc_call*/ var_rpc_call || '('
                    || case when var_return_code is null then 0 else var_return_code end || ','
                    || case when var_prev_case is null then 'null::varchar' else concat('''', var_prev_case, '''::varchar') end || ','
                    || case when var_prev_hosp is null then 'null::varchar' else concat('''', var_prev_hosp, '''::varchar') end || ','
                    || case when var_result is null then 'null::varchar' else concat('''', var_result, '''::varchar') end || ','
                    || case when var_hkid is null then 'null::varchar' else concat('''', var_hkid, '''::varchar') end || ');';
            select * from public.dblink('PMI'::text,dblink_sql::text)
            as t1(var_return INTEGER,var_result varchar) into var_return,var_result;
        --perform public.dblink_disconnect('PMI'::text);
    
       /** exception
            when others then
                    GET STACKED DIAGNOSTICS  v_message = MESSAGE_TEXT;
                    RAISE NOTICE 'Error: %', v_message;
                    perform public.dblink_disconnect('rpc_name'::text);*/*/
           
       	-- replace_dblink_by_fdw	                    
        CALL hkpmi.cpi_pq_validate_caseno(var_return ,var_prev_case, var_prev_hosp, var_result, var_hkid);
       	SET search_path TO hpi,public;

        IF var_result <> 'Y' THEN
            BEGIN
                SELECT
                    NULL
                    INTO var_message;

                IF var_return = 2 THEN
                    SELECT
                        'Invalid previous Hospital/Case Number'
                        INTO var_message;
                ELSE
                    IF var_return = 3 THEN
                        SELECT
                            'Previous case is not belonging to the patient'
                            INTO var_message;
                    ELSE
                        SELECT
                            CONCAT('Error with return code = ', CAST (var_return AS VARCHAR(2)))
                            INTO var_message;
                    END IF;
                END IF;

                raise notice 'var_ward=%', var_ward;
                IF var_case SIMILAR TO ' HN%' THEN
                    SELECT
                        Ward_code, Specialty_code
                        INTO var_ward, var_spec
                        FROM Movement
                        WHERE Case_no = var_case AND Movement_count = 1 AND Hospital_code = par_hospital_code;
                ELSE
                    SELECT NULL, NULL 
                        INTO var_ward, var_spec;
                END IF;
                INSERT INTO t$temp_link (hkid, case_no, admission_datetime, source_indicator, source_code, ward_code, specialty_code, previous_hospital, previous_case, return_message)
                VALUES (var_hkid, var_case, var_adm_dtm, var_src_ind, var_src_code, var_ward, var_spec, var_prev_hosp, var_prev_case, var_message);
            END;
        END IF;
        FETCH csr INTO var_case, var_prev_hosp, var_prev_case;
    END LOOP;
    OPEN p_refcur FOR
    SELECT
        hkid, case_no, admission_datetime, source_indicator, source_code, ward_code, specialty_code, previous_hospital, previous_case, return_message
        FROM t$temp_link order by hkid;
    CLOSE csr;

    pas_return_code := 0;
    par_return_code := 0;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "hasp_get_link_exception" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
