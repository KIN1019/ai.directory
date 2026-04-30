-- DROP PROCEDURE hpi.hasp_get_next_un(inout int4, in varchar, inout varchar);

CREATE OR REPLACE PROCEDURE hpi.hasp_get_next_un(INOUT pas_return_code integer, IN par_hosp_code character varying, INOUT par_unhkid character varying)
 LANGUAGE plpgsql
AS $procedure$
/*
- get next available UN no
- put hosp code as input parm by WL for HPI 3 Aug 99
*/
DECLARE
    var_error INTEGER;
    var_rowcount INTEGER;
    var_time varchar(8000);
    sql$rowcount BIGINT;
BEGIN
    <<abnormal_end>>
    BEGIN
        /* begin transaction */
        /* --- Modified by WL on 3 Aug 99 for HPI -- */
        IF EXISTS (SELECT
            *
            FROM hospital_config
            WHERE Un_next_HKID = Un_max_HKID AND Hospital_code = par_hosp_code) THEN
            BEGIN
                RAISE EXCEPTION USING ERRCODE := '200027';
                EXIT abnormal_end;
            END;
        END IF;
        UPDATE hospital_config
        SET Un_next_HKID = Un_next_HKID
            WHERE 1 = 2;
        /* --- Modified by WL on 3 Aug 99 for HPI --- */

        BEGIN
            SELECT
                CONCAT(Un_HKID_prefix, Un_next_HKID)
                INTO par_unhkid
                FROM hospital_config
                WHERE Hospital_code = par_hosp_code for update;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;

        IF var_error <> 0 THEN
            BEGIN
                EXIT abnormal_end;
            END;
        END IF;
        /* --- Modified by WL on 3 Aug 99 for HPI --- */
        UPDATE hospital_config
        SET Un_next_HKID = RIGHT(CONCAT('00000', CAST (CAST (Un_next_HKID AS INTEGER) + 1 AS CHAR(06))), 6)
            WHERE Hospital_code = par_hosp_code;
        GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
		raise notice 'hasp_get_next_un(56)[UPDATE]hospital_config';
        BEGIN
            var_rowcount := sql$rowcount;
            var_error := 0;
            EXCEPTION
                WHEN OTHERS THEN
                    var_error := 1;
        END;

        IF var_rowcount <> 1 THEN
            BEGIN
                RAISE EXCEPTION USING ERRCODE := '200016';
                EXIT abnormal_end;
            END;
        END IF;

        IF var_error <> 0 THEN
            BEGIN
                EXIT abnormal_end;
            END;
        END IF;
        pas_return_code := 0;
        RETURN;

        <<normal_end>>
        BEGIN
        END;
    END;
    pas_return_code := 99;
    RETURN;
END;
$procedure$
;


;ALTER PROCEDURE "hasp_get_next_un" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
