-- DROP PROCEDURE opas_get_pat_hkid(inout int4, in varchar, in int4, inout varchar);

CREATE OR REPLACE PROCEDURE opas_get_pat_hkid(INOUT pas_return_code integer, IN par_hospital character varying, IN par_patient_no integer, INOUT par_hkid character varying)
 LANGUAGE plpgsql
AS $procedure$
/* 2001-07-10 : Danny LO : change the datalength of declaration of @hkid to varchar(12) */
DECLARE
    var_patient_key varchar(8);
BEGIN
    SELECT
        RIGHT(CONCAT('00000000',
        CASE CAST (par_patient_no AS VARCHAR(8))
            WHEN '' THEN ''
            ELSE CAST (par_patient_no AS VARCHAR(8))
        END), 8)
        INTO var_patient_key;
    SELECT
        hkid
        INTO par_hkid
        FROM cpi_patient
        WHERE patient_key = var_patient_key;
END;
$procedure$
;

;ALTER PROCEDURE "opas_get_pat_hkid" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
