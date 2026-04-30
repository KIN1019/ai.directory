-- DROP PROCEDURE hpi.cms_dt_check_iso_bed(inout int4, in varchar, in varchar, in varchar, in timestamp);

CREATE OR REPLACE PROCEDURE hpi.cms_dt_check_iso_bed(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_ward_code character varying, IN par_bed_no character varying, IN par_time timestamp without time zone DEFAULT NULL::timestamp without time zone)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_iso_facilities VARCHAR(2);
    var_cubicle_service VARCHAR(3);
    var_cubicle_no VARCHAR(4);
    var_effective_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_return_value INTEGER;
    var_iso_status VARCHAR(2);
BEGIN
    IF par_time IS NULL THEN
        BEGIN
            SELECT
                timestamp_convert(localtimestamp)
                INTO par_time;
        END;
    END IF;
    select cubicle_no, effective_datetime
		INTO var_cubicle_no, var_effective_dtm
		from bed_history
		WHERE effective_datetime <= par_time 
		AND hospital_code = par_hospital_code
		AND bed_no = par_bed_no
		AND ward_code = par_ward_code
		and effective_datetime = (
		select max(effective_datetime)
		from bed_history
		WHERE effective_datetime <= par_time 
		AND hospital_code = par_hospital_code
		AND bed_no = par_bed_no 
		AND ward_code = par_ward_code
		group by hospital_code, ward_code, bed_no
		);
    SELECT
        isolation_facilities, cubicle_service
        INTO var_iso_facilities, var_cubicle_service
        FROM cubicle
        WHERE hospital_code = par_hospital_code AND ward_code = par_ward_code AND cubicle_no = var_cubicle_no AND effective_date = var_effective_dtm;

    IF var_iso_facilities IN ('A', 'AG', 'AN', 'AP', 'AI', 'B', 'BG', 'BN', 'BI', 'BP') AND var_cubicle_service IN ('I', 'A', 'ISO') THEN
        BEGIN
            pas_return_code := 1;
            RETURN;
        END;
    ELSE
        BEGIN
            pas_return_code := 0;
            RETURN;
        END;
    END IF;
END;
$procedure$
;


;ALTER PROCEDURE "cms_dt_check_iso_bed" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
