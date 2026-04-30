-- DROP PROCEDURE hpi.opas_update_sub_specialty(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in int2, in timestamp, in varchar, in varchar, in varchar, in int2, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar);

CREATE OR REPLACE PROCEDURE hpi.opas_update_sub_specialty(INOUT pas_return_code integer, IN par_specialty_code character varying, IN par_sub_specialty_code character varying, IN par_hospital_code character varying, IN par_description character varying, IN par_chi_long character varying, IN par_chi_short character varying, IN par_type character varying, IN par_phone character varying, IN par_exclusive_group smallint, IN par_am_pm_time timestamp without time zone, IN par_multi_book character varying, IN par_imis_specialty character varying, IN par_subs_control character varying, IN par_default_period smallint, IN par_default_period_unit character varying, IN par_status character varying, IN par_remark character varying, IN par_quota_control character varying, IN par_imis_service_type character varying, IN par_print_priority_no character varying)
 LANGUAGE plpgsql
AS $procedure$
/* ***** Object:  Stored Procedure dbo.opas_update_sub_specialty    Script Date: 11/10/96 15:36:58 ***** */
BEGIN
    set search_path to hpi,public;
    DELETE FROM op_sub_specialty
        WHERE specialty_code = par_specialty_code AND hospital_code = par_hospital_code AND sub_specialty = par_sub_specialty_code;

    IF par_description > '' THEN
        INSERT INTO op_sub_specialty
        VALUES (par_specialty_code, par_sub_specialty_code, par_hospital_code, par_description, par_chi_long, par_chi_short, par_type, par_phone, par_exclusive_group, par_am_pm_time, par_multi_book, par_imis_specialty, par_subs_control, par_default_period, par_default_period_unit, par_status, par_remark, par_quota_control, par_imis_service_type, par_print_priority_no);
    END IF;
    SELECT 0 INTO pas_return_code;
END;
$procedure$
;


;ALTER PROCEDURE "opas_update_sub_specialty" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
