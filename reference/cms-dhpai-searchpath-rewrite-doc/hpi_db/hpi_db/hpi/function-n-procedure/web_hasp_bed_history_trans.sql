-- DROP PROCEDURE hpi.web_hasp_bed_history_trans(inout int4, in bpchar, in int4, in timestamp, in bpchar, in bpchar, in bpchar, in bpchar, in timestamp, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in int4, in int4, in timestamp, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in bpchar, in timestamp, in bpchar, in bpchar);

CREATE OR REPLACE PROCEDURE hpi.web_hasp_bed_history_trans(INOUT pas_return_code integer, IN par_host character, IN par_seq integer, IN par_exec_datetime timestamp without time zone, IN par_hospital_code character, IN par_ward_code character, IN par_cubicle_no character, IN par_bed_no character, IN par_effective_datetime timestamp without time zone, IN par_active_status character, IN par_bed_type character, IN par_bed_category character, IN par_specialty_code character, IN par_in_service_specialty character, IN par_row_no integer, IN par_col_no integer, IN par_update_datetime timestamp without time zone, IN par_update_by character, IN par_source_system character, IN par_ciwl_indicator character, IN par_isolation_bed character, IN par_old_ward character DEFAULT NULL::bpchar, IN par_old_cubicle character DEFAULT NULL::bpchar, IN par_old_bed character DEFAULT NULL::bpchar, IN par_old_effective timestamp without time zone DEFAULT NULL::timestamp without time zone, IN par_bed_ready character DEFAULT NULL::bpchar, IN par_physical_bed_no character DEFAULT NULL::bpchar)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    INSERT INTO bed_history_trans (host, seq, exec_datetime, hospital_code, ward_code, cubicle_no, bed_no, effective_datetime, active_status, bed_type, bed_category, specialty_code, in_service_specialty, row_no, col_no, update_datetime, update_by, source_system, ciwl_indicator, isolation_bed, old_ward, old_cubicle, old_bed, old_effective, bed_ready, physical_bed_no)
    VALUES (par_host, par_seq, par_exec_datetime, par_hospital_code, par_ward_code, par_cubicle_no, par_bed_no, par_effective_datetime, par_active_status, par_bed_type, par_bed_category, par_specialty_code, par_in_service_specialty, par_row_no, par_col_no, par_update_datetime, par_update_by, par_source_system, par_ciwl_indicator, par_isolation_bed, par_old_ward, par_old_cubicle, par_old_bed, par_old_effective, par_bed_ready, par_physical_bed_no);

    pas_return_code := 0;
END;
$procedure$
;


;ALTER PROCEDURE "web_hasp_bed_history_trans" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
