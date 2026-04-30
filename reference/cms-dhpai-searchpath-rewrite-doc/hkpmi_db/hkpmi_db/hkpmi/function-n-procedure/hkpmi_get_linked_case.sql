-- DROP PROCEDURE hkpmi.hkpmi_get_linked_case(inout int4, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar);

CREATE OR REPLACE PROCEDURE hkpmi.hkpmi_get_linked_case(INOUT pas_return_code integer, IN par_hkid varchar, IN par_previous_hospital varchar, IN par_previous_case varchar,
 IN par_linked_hospital varchar, IN par_linked_case varchar, IN par_return_result varchar, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_prk VARCHAR(16);
    var_error INTEGER;
    var_row INTEGER;
    var_return INTEGER;
    sql$rowcount BIGINT;
BEGIN

    DROP TABLE IF EXISTS t$result;
    CREATE TEMPORARY TABLE t$result (
        hospital_code varchar(6) NOT NULL,
        case_no varchar(24) NOT NULL,
        adm_dtm timestamp(6) NOT NULL,
        source_indicator varchar(2) NULL,
        source_code varchar(6) NULL,
        discharge_dtm timestamp(6) NULL,
        discharge_code varchar(2) NULL,
        destination_code varchar(10) NULL
    );

    <<error_return>>
    BEGIN
		SET SEARCH_PATH TO hkpmi;
        BEGIN
            SELECT
                patient_key
                INTO var_prk
                FROM patient
                WHERE hkid = par_hkid;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            IF var_prk IS NULL THEN
                BEGIN
                    SELECT
                        - 2
                        INTO var_return;
                    EXIT error_return;
                END;
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                BEGIN
                    SELECT
                        - 2
                        INTO var_return;
                    EXIT error_return;
                END;
        END;

        IF par_previous_hospital IS NOT NULL AND par_previous_case IS NOT NULL THEN
            BEGIN
                IF NOT EXISTS (SELECT
                    patient_key
                    FROM pmi_case
                    WHERE patient_key = var_prk AND hospital_code = par_previous_hospital AND case_no = par_previous_case LIMIT 1) THEN
                    BEGIN
                        SELECT
                            - 3
                            INTO var_return;
                        EXIT error_return;
                    END;
                END IF;

                IF par_return_result = 'R' THEN
                    BEGIN
                        INSERT INTO t$result (hospital_code,case_no,adm_dtm,source_indicator,source_code,discharge_dtm,discharge_code,destination_code)
                        SELECT
                            l.hospital_code, l.case_no, c.adm_dtm, c.source_indicator, c.source_code, c.discharge_dtm, c.discharge_code, c.destination_code
                            FROM hkpmi_linked_case AS l, pmi_case AS c
                            WHERE l.previous_hospital = par_previous_hospital AND l.previous_case = par_previous_case AND l.previous_hospital = c.hospital_code AND l.previous_case = c.case_no;
                        
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                            var_row := sql$rowcount;
                            var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error := 1;
                    END;
                ELSE
                    BEGIN
                        BEGIN
                            SELECT
                                COUNT(*)
                                INTO var_row
                                FROM hkpmi_linked_case AS l, pmi_case AS c
                                WHERE l.previous_hospital = par_previous_hospital AND l.previous_case = par_previous_case AND l.previous_hospital = c.hospital_code AND l.previous_case = c.case_no;
                            var_error := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                var_error := 1;
                        END;
                    END;
                END IF;

                IF var_error <> 0 THEN
                    BEGIN
                        SELECT
                            - 4
                            INTO var_return;
                        EXIT error_return;
                    END;
                END IF;
                SELECT
                    var_row
                    INTO var_return;
            END;
        END IF;

        IF par_linked_hospital IS NOT NULL AND par_linked_case IS NOT NULL THEN
            BEGIN
                IF NOT EXISTS (SELECT
                    patient_key
                    FROM pmi_case
                    WHERE patient_key = var_prk AND hospital_code = par_linked_hospital AND case_no = par_linked_case LIMIT 1) THEN
                    BEGIN
                        SELECT
                            - 3
                            INTO var_return;
                        EXIT error_return;
                    END;
                END IF;

                IF par_return_result = 'R' THEN
                    BEGIN
                        INSERT INTO t$result (hospital_code,case_no,adm_dtm,source_indicator,source_code,discharge_dtm,discharge_code,destination_code)
                        SELECT
                            l.previous_hospital, l.previous_case, c.adm_dtm, c.source_indicator, c.source_code, c.discharge_dtm, c.discharge_code, c.destination_code
                            FROM hkpmi_linked_case AS l, pmi_case AS c
                            WHERE l.hospital_code = par_linked_hospital AND l.case_no = par_linked_case AND l.hospital_code = c.hospital_code AND l.case_no = c.case_no;
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                        var_row := sql$rowcount;
                        var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error := 1;
                    END;
                ELSE
                    BEGIN
                        BEGIN
                            SELECT
                                COUNT(*)
                                INTO var_row
                                FROM hkpmi_linked_case AS l, pmi_case AS c
                                WHERE l.hospital_code = par_linked_hospital AND l.case_no = par_linked_case AND l.hospital_code = c.hospital_code AND l.case_no = c.case_no;
                            var_error := 0;
                        EXCEPTION
                            WHEN OTHERS THEN
                                var_error := 1;
                        END;
                    END;
                END IF;

                IF var_error <> 0 THEN
                    BEGIN
                        SELECT
                            - 4
                            INTO var_return;
                        EXIT error_return;
                    END;
                END IF;
                SELECT
                    var_row
                    INTO var_return;
                EXIT error_return;
            END;
        END IF;
    END;

    OPEN p_refcur FOR 
    SELECT *
    FROM t$result;

    pas_return_code := var_return;
    RETURN;
END;
$procedure$
;


ALTER PROCEDURE "hkpmi_get_linked_case" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

