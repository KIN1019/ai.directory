-- DROP PROCEDURE cpi_get_patient_privacy(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in int4, in varchar, in varchar, inout varchar, inout varchar, inout int4, inout varchar);

CREATE OR REPLACE PROCEDURE cpi_get_patient_privacy(INOUT pas_return_code integer, IN par_patient_key character varying, IN par_hkid character varying, IN par_hospital_code character varying, IN par_case_no character varying, IN "par_userId" character varying, IN "par_functionId" integer, IN par_user_action character varying, IN par_target character varying, INOUT "par_isPrivacy" character varying DEFAULT NULL::bpchar, INOUT "par_isFirstSearch" character varying DEFAULT NULL::bpchar, INOUT par_return_code integer DEFAULT 0, INOUT par_return_message character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
BEGIN

    <<end_error>>

    BEGIN

        SELECT
            NULL
            INTO par_return_message;
        SELECT
            0
            INTO par_return_code;
        SELECT
            'N'
            INTO "par_isPrivacy";
        SELECT
            'Y'
            INTO "par_isFirstSearch";

        IF par_patient_key IS NULL THEN
            BEGIN
                IF par_hkid IS NOT NULL THEN
                    BEGIN
                        SELECT
                            patient_key
                            INTO par_patient_key
                            FROM cpi_patient
                            WHERE hkid = par_hkid;
                    END;
                END IF;

                IF par_hospital_code IS NOT NULL AND par_case_no IS NOT NULL THEN
                    BEGIN
                        IF OCTET_LENGTH(LTRIM(RTRIM(par_case_no))) = 11 THEN
                            SELECT
                                CONCAT(' ', LTRIM(RTRIM(par_case_no)))
                                INTO par_case_no;
                        END IF;

                        SELECT
                            patient_key
                            INTO par_patient_key
                            FROM cpi_case
                            WHERE hospital_code = par_hospital_code AND case_no = par_case_no;
                    END;
                END IF;
            END;
        END IF;



        IF par_target <> 'L' THEN
            BEGIN
                IF par_patient_key IS NULL OR NOT EXISTS (SELECT
                    1
                    FROM cpi_patient
                    WHERE patient_key = par_patient_key) THEN
                    BEGIN
                        SELECT
                            'Patient is not exist'
                            INTO par_return_message;
                        SELECT
                            - 1
                            INTO par_return_code;
                        EXIT end_error;
                    END;
                END IF;
            END;
        END IF;

        IF par_target = 'L' THEN
            --BEGIN
                /* for IPAS patient location only, full list of cpi_privacy_flag */
            --    OPEN p_refcur FOR
            --    SELECT
            --        hospital_code, patient_key, privacy_flag, last_update_system, last_update_function_id, last_update_user_id, last_update_datetime
            --        FROM cpi_privacy_flag;
            --END;
            raise exception '[L]IPAS patient location is not supported!';
        END IF;

        IF par_target = 'P' THEN /* for PSP */
            BEGIN
                IF EXISTS (SELECT
                    1
                    FROM cpi_privacy_flag
                    WHERE patient_key = par_patient_key) THEN
                    SELECT
                        privacy_flag
                        INTO "par_isPrivacy"
                        FROM cpi_privacy_flag
                        WHERE patient_key = par_patient_key;
                END IF;

                IF par_user_action IS NULL THEN
                    SELECT
                        'ACCESSED'
                        INTO par_user_action;
                END IF;

                IF EXISTS (SELECT
                    1
                    FROM cpi_privacy_flag_access_log
                    WHERE patient_key = par_patient_key AND access_function_id = "par_functionId" AND access_user_action = par_user_action AND access_user_id = "par_userId" AND to_char(access_datetime,'YYYY.MM.DD')=to_char(localtimestamp::TIMESTAMP WITHOUT TIME ZONE, 'YYYY.MM.DD')) THEN
                    SELECT
                        'N'
                        INTO "par_isFirstSearch";
                END IF;
                /* --select @isPrivacy as isPrivacy, @isFirstSearch as isFirstSearch */
            END;
        END IF;

        /*

        ITO would use CLAP to generate report, and all project teams
        have to write the report data in commonly-agreed format via ALS,
        so comment the codes below

        if @target = "R"

        begin
         select  hospital_code,
          patient_key,
          case_no,
          access_search_type,
          access_user_action,
          access_reason_code,
          access_reason,
          access_system,
          access_function_id,
          access_user_id,
          access_datetime
         from cpi_privacy_flag_access_log
         where patient_key = @patient_key  and
         access_user_action  = @user_action and
         access_user_id =@userId and
         convert(varchar(10), access_datetime, 102) = convert(varchar(10), getdate(), 102)
        end
        */

        IF par_target = 'W' THEN /* for Web service */
            BEGIN
                SELECT
                    privacy_flag
                    INTO "par_isPrivacy"
                    FROM cpi_privacy_flag
                    WHERE patient_key = par_patient_key;
                /* select @isPrivacy as isPrivacy */
            END;
        END IF;
        pas_return_code := 0;
        RETURN;
    END;

    pas_return_code := par_return_code;
    RETURN;

END;
$procedure$
;

;ALTER PROCEDURE "cpi_get_patient_privacy" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
