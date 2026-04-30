-- DROP PROCEDURE hkpmi_get_linked_case(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hkpmi_get_linked_case(INOUT pas_return_code integer, IN par_hkid character varying, IN par_previous_hospital character varying, IN par_previous_case character varying, IN par_linked_hospital character varying, IN par_linked_case character varying, IN par_return_result character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_prk VARCHAR(8);
    var_error INTEGER;
    var_row INTEGER;
    var_return INTEGER;
    sql$rowcount BIGINT;
BEGIN
    <<error_return>>
    BEGIN
	    SET LOCAL search_path TO hkpmi,public;
        BEGIN
            SELECT
                patient_key
                INTO var_prk
                FROM patient
                WHERE hkid = par_hkid;
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

            IF sql$rowcount <> 1 THEN
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
                    *
                    FROM pmi_case
                    WHERE patient_key = var_prk AND hospital_code = par_previous_hospital AND case_no = par_previous_case) THEN
                    BEGIN
                        SELECT
                            - 3
                            INTO var_return;
                        EXIT error_return;
                    END;
                END IF;

                IF par_return_result = 'R' THEN
                    BEGIN
                        -- OPEN p_refcur FOR
                        SELECT
                            l.hospital_code, l.case_no, c.adm_dtm, c.source_indicator, c.source_code, c.discharge_dtm, c.discharge_code, c.destination_code
                            FROM hkpmi_linked_case AS l, pmi_case AS c
                            WHERE l.previous_hospital = par_previous_hospital AND l.previous_case = par_previous_case AND l.previous_hospital = c.hospital_code AND l.previous_case = c.case_no;
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                        BEGIN
                            var_row := sql$rowcount;
                            var_error := 0;
                            EXCEPTION
                                WHEN OTHERS THEN
                                    var_error := 1;
                        END;
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
                    *
                    FROM pmi_case
                    WHERE patient_key = var_prk AND hospital_code = par_linked_hospital AND case_no = par_linked_case) THEN
                    BEGIN
                        SELECT
                            - 3
                            INTO var_return;
                        EXIT error_return;
                    END;
                END IF;

                IF par_return_result = 'R' THEN
                    BEGIN
                        -- OPEN p_refcur_2 FOR
                        SELECT
                            l.previous_hospital, l.previous_case, c.adm_dtm, c.source_indicator, c.source_code, c.discharge_dtm, c.discharge_code, c.destination_code
                            FROM hkpmi_linked_case AS l, pmi_case AS c
                            WHERE l.hospital_code = par_linked_hospital AND l.case_no = par_linked_case AND l.hospital_code = c.hospital_code AND l.case_no = c.case_no;
                        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

                        BEGIN
                            var_row := sql$rowcount;
                            var_error := 0;
                            EXCEPTION
                                WHEN OTHERS THEN
                                    var_error := 1;
                        END;
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
    pas_return_code := var_return;
   	RESET search_path;
    RETURN;
END;
$procedure$
;

ALTER PROCEDURE "hkpmi_get_linked_case" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";