-- DROP PROCEDURE hkpmi_check_merge(inout int4, in bpchar, in bpchar, in bpchar, in int4, in bpchar);

CREATE OR REPLACE PROCEDURE hkpmi_check_merge(INOUT pas_return_code integer, IN par_hospital_code VARCHAR, IN par_from_hkid VARCHAR, IN par_to_hkid VARCHAR, IN par_error integer, IN par_check_type VARCHAR DEFAULT 'MERGE'::VARCHAR)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    <<program_return>>
    BEGIN
        SET search_path TO hkpmi, public; 
        SELECT
            0
            INTO par_error;
        /*
        if not exists(select * from patient
        	where hkid = @from_hkid)
        begin
        	select @error = 1
        	goto program_return
        end
        */
        IF par_check_type = 'MERGE' THEN
            BEGIN
                IF NOT EXISTS (SELECT
                    *
                    FROM patient
                    WHERE hkid = par_to_hkid) THEN
                    BEGIN
                        SELECT
                            2
                            INTO par_error;
                        EXIT program_return;
                    END;
                END IF;

                IF EXISTS (SELECT
                    *
                    FROM patient AS p, pmi_case AS c
                    WHERE hkid = par_from_hkid AND p.patient_key = c.patient_key AND c.hospital_code <> par_hospital_code) THEN
                    BEGIN
                        SELECT
                            3
                            INTO par_error;
                        EXIT program_return;
                    END;
                END IF;
                /* ----@From_hkid is Pseudo-ID */
                IF LTRIM(RTRIM(SUBSTRING(par_from_hkid, 1, 1))) = 'U' THEN
                    BEGIN
                        /* --- For Merge patient */
                        IF EXISTS (SELECT
                            1
                            FROM hkpmi_uid_table
                            WHERE uid_hkid = par_from_hkid AND ((link_hkid = par_to_hkid AND link_status = 'CD') OR /* ---Merge to Link ID: Reject if already verified Diff */ (link_hkid <> par_to_hkid AND link_status <> 'CD') /* --Merge to other ID: Reject if NOT  verified Diff */)) THEN
                            BEGIN
                                SELECT
                                    4
                                    INTO par_error;
                                EXIT program_return;
                            END;
                        END IF;
                    END;
                END IF;
                /* --- SL 20090114 SL : reject  @from_hkid ( link_hkid) merge to @to_hkid(uid_hkid) */

                IF LTRIM(RTRIM(SUBSTRING(par_from_hkid, 1, 1))) <> 'U' THEN
                    BEGIN
                        IF EXISTS (SELECT
                            1
                            FROM hkpmi_uid_table
                            WHERE link_hkid = par_from_hkid AND uid_hkid = par_to_hkid) THEN
                            BEGIN
                                SELECT
                                    5
                                    INTO par_error;
                                EXIT program_return;
                            END;
                        END IF;
                    END;
                END IF;

                IF LTRIM(RTRIM(SUBSTRING(par_from_hkid, 1, 1))) <> 'U' THEN
                    BEGIN
                        IF EXISTS (SELECT
                            1
                            FROM hkpmi_uid_table
                            WHERE link_hkid = par_from_hkid AND link_status in ('L','PS')) THEN
                            BEGIN
                                SELECT
                                    7
                                    INTO par_error;
                                EXIT program_return;
                            END;
                        END IF;
                    END;
                END IF;
            END;
        END IF;
        /*
        NO checking for MOve episodes
        if @check_type ='MOVE'
        begin
        	if exists (select 1 from hkpmi_uid_table where
        			uid_hkid=@from_hkid AND	link_status='L'	)
        	begin
        		select @error = 5
        		goto program_return
        	end
        end
        */
        IF par_check_type = 'CHANG' THEN
            BEGIN
                IF EXISTS (SELECT
                    1
                    FROM hkpmi_uid_table
                    WHERE uid_hkid = par_from_hkid AND link_status IN ('L', 'PS')) THEN
                    BEGIN
                        SELECT
                            6
                            INTO par_error;
                        EXIT program_return;
                    END;
                END IF;
            END;
        END IF;
    END;
    pas_return_code := par_error;
    RETURN;
END;
$procedure$
;

ALTER PROCEDURE "hkpmi_check_merge" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

