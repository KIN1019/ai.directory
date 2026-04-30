CREATE OR REPLACE PROCEDURE hasp_check_iso_bed(INOUT pas_return_code int, IN par_hospital_code VARCHAR, IN par_ward_code VARCHAR, IN par_bed_no VARCHAR)
AS 
$BODY$
DECLARE
    var_iso_facilities VARCHAR(4);
    var_cubicle_service VARCHAR(6);
    var_cubicle_no VARCHAR(8);
    var_effective_dtm TIMESTAMP WITHOUT TIME ZONE;
BEGIN
    SELECT
        cubicle_no, effective_datetime
        INTO var_cubicle_no, var_effective_dtm
        FROM (SELECT
            cubicle_no, effective_datetime, hospital_code, ward_code, bed_no
            FROM bed_history) AS ungrouped_query
        INNER JOIN (SELECT
            hospital_code, ward_code, bed_no, MAX(effective_datetime) AS max_1
            FROM bed_history
            WHERE effective_datetime <= timestamp_convert(localtimestamp) AND hospital_code = par_hospital_code AND bed_no = par_bed_no AND ward_code = par_ward_code
            GROUP BY hospital_code, ward_code, bed_no) AS grouped_query
            ON (ungrouped_query.hospital_code = grouped_query.hospital_code OR (ungrouped_query.hospital_code IS NULL AND grouped_query.hospital_code IS NULL))
        WHERE effective_datetime = max_1;
    SELECT
        isolation_facilities, cubicle_service
        INTO var_iso_facilities, var_cubicle_service
        FROM cubicle
        WHERE hospital_code = par_hospital_code AND ward_code = par_ward_code AND cubicle_no = var_cubicle_no AND effective_date = var_effective_dtm;

    IF var_iso_facilities IN ('A', 'AG', 'AN', 'AP', 'AI', 'B', 'BG', 'BN', 'BI', 'BP', 'C', 'D') AND var_cubicle_service IN ('ISO') THEN
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
$BODY$
LANGUAGE plpgsql;