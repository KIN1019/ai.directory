-- DROP PROCEDURE hpi.hasp_del_user_group_detail(inout int4, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hpi.hasp_del_user_group_detail(INOUT pas_return_code integer, IN par_group_id character varying, IN par_hosp_code character varying)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
	BEGIN
		IF NOT EXISTS (SELECT
                            1
                            FROM user_profile
                            WHERE group_id = par_group_id and hospital_code = par_hosp_code) THEN
			delete from user_group where group_id = par_group_id and hospital_code = par_hosp_code;
			delete from user_group_detail where group_id = par_group_id and hospital_code = par_hosp_code;
		END IF;
		pas_return_code := 0;
		RETURN;
	END;
	exception
        when others then
        BEGIN
            pas_return_code := -1;
            RETURN;
        end;
END;	

$procedure$
;


;ALTER PROCEDURE "hasp_del_user_group_detail" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
