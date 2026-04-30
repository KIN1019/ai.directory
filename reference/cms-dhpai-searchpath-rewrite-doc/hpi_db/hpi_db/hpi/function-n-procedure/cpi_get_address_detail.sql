-- DROP PROCEDURE cpi_get_address_detail(inout int4, in int4, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar);

CREATE OR REPLACE PROCEDURE cpi_get_address_detail(INOUT pas_return_code integer, IN par_record_id integer, INOUT par_address_eng character varying, INOUT par_address_chi character varying, INOUT par_district_code character varying, INOUT par_eh_eng character varying, INOUT par_eh_chi character varying)
 LANGUAGE plpgsql
AS $procedure$
begin
	set search_path to hpi;
    SELECT COALESCE(RTRIM(bldg_eng) || CASE WHEN estate_eng IS NOT NULL OR street_eng IS NOT NULL THEN ', ' ELSE '' END,
                    '') ||
           COALESCE(RTRIM(estate_eng) || CASE WHEN street_eng IS NOT NULL THEN ', ' ELSE '' END, '') ||
           COALESCE(RTRIM(house_no) || ' ', '') || COALESCE(RTRIM(street_eng), ''),
           RTRIM(area_chi) || RTRIM(district_chi) ||
           COALESCE(RTRIM(street_chi), '') ||
           COALESCE(RTRIM(house_no) || '號', '') ||
           COALESCE(RTRIM(estate_chi), '') ||
           COALESCE(RTRIM(bldg_chi), ''),
           a.district_code,
           d.eh_name,
           d.eh_chinese_name
    INTO par_address_eng,par_address_chi,par_district_code,par_eh_eng,par_eh_chi
    FROM address_detail a
             LEFT JOIN elderly_home_table d ON a.record_id = d.eh_address_id
             INNER JOIN district b ON a.district_code = b.district_code
             INNER JOIN district_area c ON b.district_area = c.area_code
    WHERE a.record_id = par_record_id;
END;
$procedure$
;

;ALTER PROCEDURE "cpi_get_address_detail" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
