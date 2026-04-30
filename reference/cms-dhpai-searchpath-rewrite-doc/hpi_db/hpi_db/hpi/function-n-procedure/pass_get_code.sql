CREATE OR REPLACE FUNCTION pass_get_code(IN par_code_table VARCHAR, IN par_time TIMESTAMP WITHOUT TIME ZONE DEFAULT null)
RETURNS SETOF refcursor
LANGUAGE plpgsql
AS 
$function$
DECLARE
    var_sql_text VARCHAR(255);
    var_hospital VARCHAR(6);
	p_refcur refcursor;
BEGIN
    SELECT
        hospital_code
        INTO var_hospital
        FROM hospital;
    /*
    select @sql_text =
    	case when @code_table = discharge_type then select * from discharge_type where discharge_code not in ('7', '9') order by discharge_code ASC
    	when @code_table = active_specialty then select * from ip_specialty where hospital_code=+@hospital+ and effective_date<=getdate() group by specialty_code having effective_date = max(effective_date)order by specialty_code
    	when @code_table = destination then select * from destination
    	when @code_table = source then select * from source
    	else 
    end
    
    exec (@sql_text)
    */
    IF par_code_table = 'discharge_type' THEN
        BEGIN
            OPEN p_refcur FOR
            SELECT
                discharge_code, RTRIM(description) AS description, RTRIM(short_description) AS short_description
                FROM discharge_type
                WHERE discharge_code NOT IN ('7', '9')
                ORDER BY discharge_code ASC NULLS FIRST;
        END;
    END IF;

    IF par_code_table = 'active_specialty' THEN
        BEGIN
            IF par_time = NULL THEN
                BEGIN
                    SELECT
                        localtimestamp
                        INTO par_time;
                END;
            END IF;
            OPEN p_refcur FOR
            SELECT
                isr.hospital_code, isr.specialty_code, RTRIM(isr.description), isr.treatment_location, isr.imis_code, isr.from_age, isr.to_age, isr.sex, isr.security_count, isr.active_status, CONCAT(to_char(isr.effective_date, 'DD-Mon-YYYY'), ' ', to_char(isr.effective_date, 'hh:mm:ss:mmm')) AS effective_time, isr.user_define, isr.treatment_flag, e.EIS_code
                FROM (SELECT
                    hospital_code, ungrouped_query.specialty_code, description, treatment_location, imis_code, from_age, to_age, sex, security_count, active_status, effective_date, user_define, treatment_flag
                    FROM (SELECT
                        i.hospital_code, i.specialty_code, i.description, i.treatment_location, i.imis_code, i.from_age, i.to_age, i.sex, i.security_count, i.active_status, i.effective_date, i.user_define, i.treatment_flag
                        FROM ip_specialty AS i) AS ungrouped_query
                    INNER JOIN (SELECT
                        i.specialty_code, MAX(i.effective_date) AS max_1
                        FROM ip_specialty AS i
                        WHERE i.hospital_code = var_hospital AND i.effective_date <= par_time
                        GROUP BY i.specialty_code) AS grouped_query
                        ON (ungrouped_query.specialty_code = grouped_query.specialty_code OR (ungrouped_query.specialty_code IS NULL AND grouped_query.specialty_code IS NULL))
                    WHERE effective_date = max_1 AND active_status = 'A') AS isr
                LEFT OUTER JOIN IMIS AS e
                    ON isr.imis_code = e.IMIS_code
                ORDER BY isr.specialty_code NULLS FIRST;
        END;
    END IF;

    IF par_code_table = 'source_destination' THEN
        BEGIN
            OPEN p_refcur FOR
            SELECT
                destination_code AS code, description
                FROM destination;
        END;
    END IF;

    IF par_code_table = 'source_type' THEN
        BEGIN
            OPEN p_refcur FOR
            SELECT
                source_indicator AS code, description
                FROM source;
        END;
    END IF;

    IF par_code_table = 'active_ward' THEN
        BEGIN
            OPEN p_refcur FOR
            SELECT
                hospital_code, ungrouped_query.ward_code, description, treatment_location, location, active_status, ungrouped_query.effective_date, user_define, care_category, default_specialty, wristband_no
                FROM (SELECT
                    hospital_code, ward_code, description, treatment_location, location, active_status, CONCAT(to_char(effective_date, 'DD-Mon-YYYY'), ' ', to_char(effective_date, 'hh:mm:ss:mmm')) AS effective_date, user_define, care_category, default_specialty, wristband_no, effective_date
                    FROM ward) AS ungrouped_query
                INNER JOIN (SELECT
                    ward_code, MAX(effective_date) AS max_2
                    FROM ward
                    WHERE hospital_code = var_hospital AND effective_date <= localtimestamp
                    GROUP BY ward_code) AS grouped_query
                    ON (ungrouped_query.ward_code = grouped_query.ward_code OR (ungrouped_query.ward_code IS NULL AND grouped_query.ward_code IS NULL))
                WHERE effective_date = max_2 AND active_status = 'A'
                ORDER BY hospital_code NULLS FIRST, ward_code NULLS FIRST;
        END;
    END IF;

    IF par_code_table = 'ward_location' THEN
        BEGIN
            OPEN p_refcur FOR
            SELECT
                ungrouped_query.hospital_code, RTRIM(ward_code), RTRIM(location_code), active_status, ungrouped_query.effective_date, RTRIM(location_desc)
                FROM (SELECT
                    hospital_code, RTRIM(ward_code), RTRIM(location_code), active_status, CONCAT(to_char(effective_date, 'DD-Mon-YYYY'), ' ', to_char(effective_date, 'hh:mm:ss:mmm')) AS effective_date, RTRIM(location_desc), effective_date
                    FROM ward_location) AS ungrouped_query
                INNER JOIN (SELECT
                    hospital_code, ward_code, MAX(effective_date) AS max_2
                    FROM ward_location
                    WHERE hospital_code = var_hospital AND effective_date <= localtimestamp
                    GROUP BY hospital_code, ward_code) AS grouped_query
                    ON (ungrouped_query.hospital_code = grouped_query.hospital_code OR (ungrouped_query.hospital_code IS NULL AND grouped_query.hospital_code IS NULL))
                WHERE effective_date = max_2 AND active_status = 'A'
                ORDER BY hospital_code NULLS FIRST, ward_code NULLS FIRST;
        END;
    END IF;
END;
$function$;