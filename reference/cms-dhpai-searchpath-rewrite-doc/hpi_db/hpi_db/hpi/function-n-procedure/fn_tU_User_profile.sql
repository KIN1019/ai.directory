-- DROP FUNCTION "fn_tU_User_profile"();

CREATE OR REPLACE FUNCTION "fn_tU_User_profile"()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
/* 20111228 : Prevent Update for NON CUID User_ID */
/* 20161212: enable Logging feature */
/* UPDATE trigger on User_profile */
DECLARE
    var_numrows INTEGER;
    var_nullcnt INTEGER;
    var_validcnt INTEGER;
    "var_insUser_ID" CHAR(8);
    var_cuid_user_flag CHAR(1);
    var_ins_user_id CHAR(8);
    var_ins_hosp_code CHAR(3);
    var_hosp_code CHAR(3);
    var_start_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_input_parm1 VARCHAR(255);
    /* Org Value */
    var_output_parm1 VARCHAR(255);
    /* New Value */
    var_user_id VARCHAR(12);
    var_term_id VARCHAR(12);
    var_monitor_type CHAR(3);
    var_rowcount$aws$ INTEGER;
    update$Group_ID BOOLEAN = FALSE;
    update$Expiration_date BOOLEAN = FALSE;
    update$cuid_flag BOOLEAN = FALSE;
    update$HKID BOOLEAN = FALSE;
BEGIN
    <<error>>
    BEGIN
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$Group_ID = TRUE;
            WHEN 'UPDATE' THEN
                update$Group_ID = ((SELECT
                    array_agg(Group_ID)
                    FROM deleted) != (SELECT
                    array_agg(Group_ID)
                    FROM inserted));
            ELSE
                update$Group_ID := FALSE;
        END CASE;
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$Expiration_date = TRUE;
            WHEN 'UPDATE' THEN
                update$Expiration_date = ((SELECT
                    array_agg(Expiration_date)
                    FROM deleted) != (SELECT
                    array_agg(Expiration_date)
                    FROM inserted));
            ELSE
                update$Expiration_date := FALSE;
        END CASE;
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$cuid_flag = TRUE;
            WHEN 'UPDATE' THEN
                update$cuid_flag = ((SELECT
                    array_agg(cuid_flag)
                    FROM deleted) != (SELECT
                    array_agg(cuid_flag)
                    FROM inserted));
            ELSE
                update$cuid_flag := FALSE;
        END CASE;
        CASE TG_OP
            WHEN 'INSERT' THEN
                update$HKID = TRUE;
            WHEN 'UPDATE' THEN
                update$HKID = ((SELECT
                    array_agg(HKID)
                    FROM deleted) != (SELECT
                    array_agg(HKID)
                    FROM inserted));
            ELSE
                update$HKID := FALSE;
        END CASE;

        IF (TG_OP = 'INSERT') THEN
            SELECT
                count(1)
                FROM inserted
                INTO var_rowcount$aws$;
        ELSE
            SELECT
                count(1)
                FROM deleted
                INTO var_rowcount$aws$;
        END IF;
        /* INS/UPD */
        var_numrows := var_rowcount$aws$;
        SELECT
            NULL
            INTO var_cuid_user_flag;
        SELECT
            aws_sapase_ext.user_id, "Hospital_code"
            INTO var_ins_user_id, var_ins_hosp_code
            FROM inserted;

        IF var_numrows = 0 THEN
            RETURN NULL;
        END IF;

        IF var_numrows > 1 THEN
            BEGIN
                RAISE EXCEPTION '% % ', 'Update', 'NOT allow to update Multi-Records on User_profile' USING ERRCODE := '200013';
                EXIT error;
            END;
        END IF;
        /* User_group join with User_profile ON CHILD UPDATE RESTRICT */
        IF update$Group_ID THEN
            BEGIN
                SELECT
                    0
                    INTO var_nullcnt;
                SELECT
                    COUNT(*)
                    INTO var_validcnt
                    FROM inserted, "User_group"
                    WHERE inserted."Group_ID" = "User_group"."Group_ID";

                IF var_validcnt + var_nullcnt != var_numrows THEN
                    BEGIN
                        RAISE EXCEPTION '% % % ', 'UPDATE', 'User_profile', 'User_group' USING ERRCODE := '200012';
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;
        /* ----2011-12-22 -- NOT allow to update for NON-cuid user : cuid_flag */
        /* Y = CUID Match (both user_id/hkid) */
        /* S = Support A/C */
        /* N = NOT CUID Match  -- UnMatched_ALL_Not_Found -Both ID and HKID not found in CUID */
        /* F = ID found, but HKID mismatched */
        /* M = HKID found, but ID mismatched */
        /* K = to skip this Trigger checking */
        /* U = Undefined */
        IF (update$Expiration_date) OR ((NOT update$cuid_flag) AND (NOT update$HKID)) THEN
            BEGIN
                SELECT
                    "User_profile".cuid_flag
                    INTO var_cuid_user_flag
                    FROM "User_profile"
                    WHERE "User_profile"."Hospital_code" = var_ins_hosp_code AND "User_profile"."User_ID" = var_ins_user_id;

                IF var_cuid_user_flag IN ('N', 'F', 'M', 'U') THEN
                    BEGIN
                        RAISE EXCEPTION '% ', 'The User ID is not in CUID format, so the update is not allowed' USING ERRCODE := '299999';
                        EXIT error;
                    END;
                END IF;
            END;
        END IF;
        /* ------------------------------------------------------------------------------ */
        /* 20161215 : new records <pas_sys_perf_log>  with monitor_type='USER_PROF' -- */
        /* insert pas_monitor values('IPAS','USER_PROF','20161215','Records generated by User_profile Ins/Upd trigger',null,@hosp_code,null,null,null,'IPAS','ADT',getdate()) */
        /* ------------------------------------------------------------------------------ */
        SELECT
            current_user
            INTO var_user_id;
        SELECT
            aws_sapase_ext.host_name()
            INTO var_term_id;
        SELECT
            'UPD'
            INTO var_monitor_type;
        SELECT
            timestamp_convert(localtimestamp)
            INTO var_start_dtm;
        SELECT
            "Hospital_code"
            INTO var_hosp_code
            FROM "Hospital";
        /* Org Value -- */
        SELECT
            CONCAT(aws_sapase_ext.user_id, ':', deleted."Group_ID", ':', deleted."Password", ':', deleted."Department", ':', deleted."Name", ':', CAST (deleted."Authority_code" AS CHAR(12)), ':', to_char(deleted."Expiration_date"::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), ':', to_char(deleted."Effective_date"::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), ':', deleted."Rank_code", ':', deleted."Menu", ':', CAST (deleted."DT_security_code" AS CHAR(12)), ':', deleted."Hospital_code", ':', deleted."HKID", ':', deleted."User_title", ':', deleted."DT_enable_flag", ':', to_char(deleted."DT_effective_date"::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), ':', to_char(deleted."DT_expiration_date"::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), ':', to_char(deleted."Password_expiration_date"::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), ':', CAST (deleted."Password_retry_count" AS CHAR(12)), ':', deleted.cuid_flag)
            INTO var_input_parm1
            FROM deleted;
        /* New Value -- */
        SELECT
            CONCAT(aws_sapase_ext.user_id, ':', inserted."Group_ID", ':', inserted."Password", ':', inserted."Department", ':', inserted."Name", ':', CAST (inserted."Authority_code" AS CHAR(12)), ':', to_char(inserted."Expiration_date"::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), ':', to_char(inserted."Effective_date"::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), ':', inserted."Rank_code", ':', inserted."Menu", ':', CAST (inserted."DT_security_code" AS CHAR(8)), ':', inserted."Hospital_code", ':', inserted."HKID", ':', inserted."User_title", ':', inserted."DT_enable_flag", ':', to_char(inserted."DT_effective_date"::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), ':', to_char(inserted."DT_expiration_date"::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), ':', to_char(inserted."Password_expiration_date"::TIMESTAMP WITHOUT TIME ZONE, 'YYYYMMDD'), ':', CAST (inserted."Password_retry_count" AS CHAR(12)), ':', inserted.cuid_flag)
            INTO var_output_parm1
            FROM inserted;
        /* --exec cpi..pas_ins_perf_log @hosp_code, 'IPAS', 'USER_PROF', @monitor_type, null,null,@user_id, @term_id, @start_dtm,null, -- CPI */
        CALL pas_ins_perf_log(pas_return_code, var_hosp_code, 'IPAS', 'USER_PROF', var_monitor_type, NULL, NULL, var_user_id, var_term_id, var_start_dtm, NULL, NULL, NULL, NULL, var_input_parm1, NULL, NULL, var_output_parm1, NULL);
        /* ------------------------------------------------------------------------------ */
        RETURN NULL;
    END;
    ROLLBACK;
    RETURN NULL;
END;
$function$
;

;ALTER FUNCTION "fn_tU_User_profile" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
