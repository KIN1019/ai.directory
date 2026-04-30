-- DROP PROCEDURE hpi.web_hasp_bed_allocation_trans(inout int4, in varchar, in int4, in timestamp, in varchar, in varchar, in varchar, in varchar, in timestamp, in int4, in int4, in int4, in int4, in varchar, in timestamp, in varchar, in varchar, in varchar, in timestamp);

CREATE OR REPLACE PROCEDURE hpi.web_hasp_bed_allocation_trans(INOUT pas_return_code integer, IN par_host character varying, IN par_seq integer, IN par_exec_datetime timestamp without time zone, IN par_hospital_code character varying, IN par_ward_code character varying, IN par_specialty_code character varying, IN par_original_specialty character varying, IN par_effective_date timestamp without time zone, IN par_official_bed integer, IN par_day_bed integer, IN par_isolation_bed integer, IN par_isolation_day integer, IN par_update_by character varying, IN par_update_dtm timestamp without time zone, IN par_old_ward character varying DEFAULT NULL::character varying, IN par_old_specialty character varying DEFAULT NULL::character varying, IN par_old_original character varying DEFAULT NULL::character varying, IN par_old_effective timestamp without time zone DEFAULT NULL::timestamp without time zone)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    INSERT INTO bed_allocation_trans (host, seq, exec_datetime, hospital_code, ward_code, specialty_code, original_specialty, effective_date, official_bed, day_bed, isolation_bed, isolation_day, update_by, update_dtm, old_ward, old_specialty, old_original, old_effective)
    VALUES (par_host, par_seq, par_exec_datetime, par_hospital_code, par_ward_code, par_specialty_code, par_original_specialty, par_effective_date, par_official_bed, par_day_bed, par_isolation_bed, par_isolation_day, par_update_by, par_update_dtm, par_old_ward, par_old_specialty, par_old_original, par_old_effective);
    pas_return_code := 0;
END;
$procedure$
;


;ALTER PROCEDURE "web_hasp_bed_allocation_trans" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
