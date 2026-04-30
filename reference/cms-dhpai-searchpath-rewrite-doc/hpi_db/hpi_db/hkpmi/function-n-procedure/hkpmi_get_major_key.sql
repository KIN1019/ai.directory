-- DROP PROCEDURE hkpmi_get_major_key(inout int4, in varchar, inout varchar, inout varchar, inout varchar, inout timestamp, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout timestamp, inout varchar, inout varchar);

CREATE OR REPLACE PROCEDURE hkpmi_get_major_key(INOUT pas_return_code integer, IN par_hkid character varying, INOUT par_prk character varying, INOUT par_name character varying, INOUT par_sex character varying, INOUT par_dob timestamp without time zone, INOUT par_exact_dob character varying, INOUT par_ccc_1 character varying, INOUT par_ccc_2 character varying, INOUT par_ccc_3 character varying, INOUT par_ccc_4 character varying, INOUT par_ccc_5 character varying, INOUT par_ccc_6 character varying, INOUT par_update_by character varying, INOUT par_src_system character varying, INOUT par_update_dtm timestamp without time zone, INOUT par_hosp_code character varying, INOUT par_document_flag character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    sql$rowcount BIGINT;
begin
	SET LOCAL search_path TO hkpmi,public;
    SELECT
        patient_name, patient_key, sex, dob, exact_dob_flag, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, update_by, source_system, update_hospital, system_dtm, SUBSTRING(filler, 1, 1)
        INTO par_name, par_prk, par_sex, par_dob, par_exact_dob, par_ccc_1, par_ccc_2, par_ccc_3, par_ccc_4, par_ccc_5, par_ccc_6, par_update_by, par_src_system, par_hosp_code, par_update_dtm, par_document_flag
        FROM patient
        WHERE hkid = par_hkid;
    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

    IF sql$rowcount <> 1 THEN
        pas_return_code := - 1;
        RETURN;
    ELSE
        pas_return_code := 0;
        RETURN;
    END IF;
    pas_return_code := 0;
   	RESET search_path;
    RETURN;
END;
$procedure$
;

ALTER PROCEDURE "hkpmi_get_major_key" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";