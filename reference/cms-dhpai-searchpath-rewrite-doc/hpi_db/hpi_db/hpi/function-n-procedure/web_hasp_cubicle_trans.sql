-- DROP PROCEDURE hpi.web_hasp_cubicle_trans(inout int4, in varchar, in int4, in timestamp, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in varchar, in varchar, in int4, in int4, in varchar, in varchar, in timestamp);

CREATE OR REPLACE PROCEDURE hpi.web_hasp_cubicle_trans(INOUT pas_return_code integer, IN par_host character varying, IN par_seq integer, IN par_exec_datetime timestamp without time zone, IN par_hospital_code character varying, IN par_ward_code character varying, IN par_cubicle_no character varying, IN par_effective_date timestamp without time zone, IN par_active_status character varying, IN par_description character varying, IN par_isolation_facilities character varying, IN par_project_category character varying, IN par_care_category character varying, IN par_sex character varying, IN par_treatment_location character varying, IN par_update_by character varying, IN par_update_datetime timestamp without time zone, IN par_source_system character varying, IN par_patient_category character varying, IN par_cubicle_service character varying, IN par_official_bed integer, IN par_day_bed integer, IN par_old_ward character varying DEFAULT NULL::character varying, IN par_old_cubicle character varying DEFAULT NULL::character varying, IN par_old_effective timestamp without time zone DEFAULT NULL::timestamp without time zone)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    INSERT INTO cubicle_trans (host, seq, exec_datetime, hospital_code, ward_code, cubicle_no, effective_date, active_status, description, isolation_facilities, project_category, care_category, sex, treatment_location, update_by, update_datetime, source_system, patient_category, cubicle_service, official_bed, day_bed, old_ward, old_cubicle, old_effective)
    VALUES (par_host, par_seq, par_exec_datetime, par_hospital_code, par_ward_code, par_cubicle_no, par_effective_date, par_active_status, par_description, par_isolation_facilities, par_project_category, par_care_category, par_sex, par_treatment_location, par_update_by, par_update_datetime, par_source_system, par_patient_category, par_cubicle_service, par_official_bed, par_day_bed, par_old_ward, par_old_cubicle, par_old_effective);

    pas_return_code := 0;
END;
$procedure$
;


;ALTER PROCEDURE "web_hasp_cubicle_trans" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
