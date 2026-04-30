-- DROP FUNCTION hpi.opas_get_nok_list(varchar);

CREATE OR REPLACE FUNCTION hpi.opas_get_nok_list(par_hkid character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
declare p_refcur refcursor;
pas_return_code INTEGER;
/* ***** Object:  Stored Procedure opas_get_nok_list    Script Date: 11/10/96 15:33:39 ***** */
/* 2023-10-31 OPAS-871 AikenYu OPAS F1 NOK add mobile phone field funtion, Adding another phone field to a query */
BEGIN
   set search_path to hpi, public;
    OPEN p_refcur FOR
    SELECT
        pat.patient_no, nok.priority, nok.nok_name, nok.hkid, nok.building, nok.room, nok.floor, nok.block, nok.district, nok.phone1, nok.phone2, nok.address_indicator, nok.relationship, nok.update_by, nok.update_dtm, nok.major_nok, nok.mobile_phone
        FROM cpi_nok AS nok, cpi_patient AS pat
        WHERE pat.hkid = par_hkid AND nok.patient_key = pat.patient_key;

    return next p_refcur;
END;
$function$
;

;ALTER FUNCTION "opas_get_nok_list" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
