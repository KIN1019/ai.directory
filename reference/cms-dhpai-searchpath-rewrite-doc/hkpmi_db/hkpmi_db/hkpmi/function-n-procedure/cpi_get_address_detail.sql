-- DROP FUNCTION hkpmi.cpi_get_address_detail(int4);

CREATE OR REPLACE FUNCTION hkpmi.cpi_get_address_detail(par_record_id integer)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
declare p_refcur refcursor;
BEGIN
    OPEN p_refcur FOR
    SELECT
        a.record_id, CONCAT((CASE
            WHEN bldg_eng IS NULL THEN ''
            ELSE RTRIM(bldg_eng) || (CASE
                WHEN CONCAT(COALESCE(estate_eng, ''), COALESCE(street_eng, '')) IS NULL THEN ''
                ELSE ', '
            END)
        END), (CASE
            WHEN estate_eng IS NULL THEN ''
            ELSE CONCAT(RTRIM(estate_eng), (CASE
                WHEN street_eng IS NULL THEN ''
                ELSE ', '
            END))
        END), (CASE
            WHEN house_no IS NULL THEN ''
            ELSE CONCAT(RTRIM(house_no), ' ')
        END), (CASE
            WHEN street_eng IS NULL THEN ''
            ELSE RTRIM(street_eng)
        END), ', ', RTRIM(b.district_name), ', ', RTRIM(c.area_name)) AS address_eng, CONCAT((CASE
            WHEN d.eh_chinese_name IS NULL THEN ''
            ELSE CONCAT(RTRIM(d.eh_chinese_name), '--')
        END), RTRIM(area_chi), RTRIM(district_chi), (CASE
            WHEN street_chi IS NULL THEN ''
            ELSE RTRIM(street_chi)
        END), (CASE
            WHEN house_no IS NULL THEN ''
            ELSE CONCAT(RTRIM(house_no),
            CASE
                WHEN 184 BETWEEN 1 AND 255 THEN CHR(184)
                ELSE NULL
            END,
            CASE
                WHEN 185 BETWEEN 1 AND 255 THEN CHR(185)
                ELSE NULL
            END)
        END), (CASE
            WHEN estate_chi IS NULL THEN ''
            ELSE RTRIM(estate_chi)
        END), (CASE
            WHEN bldg_chi IS NULL THEN ''
            ELSE RTRIM(bldg_chi)
        END)) AS address_chi,
        CASE
            WHEN a.bldg_eng IS NULL THEN ''
            ELSE a.bldg_eng
        END AS building_eng,
        CASE
            WHEN a.bldg_chi IS NULL THEN ''
            ELSE a.bldg_chi
        END AS building_chi,
        CASE
            WHEN a.estate_eng IS NULL THEN ''
            ELSE a.estate_eng
        END AS estate_eng,
        CASE
            WHEN a.estate_chi IS NULL THEN ''
            ELSE a.estate_chi
        END AS estate_chi,
        CASE
            WHEN a.house_no IS NULL THEN ''
            ELSE a.house_no
        END AS house_no,
        CASE
            WHEN a.street_eng IS NULL THEN ''
            ELSE a.street_eng
        END AS street_eng,
        CASE
            WHEN a.street_chi IS NULL THEN ''
            ELSE a.street_chi
        END AS street_chi, RTRIM(b.district_name) AS district_name, RTRIM(b.district_chi) AS district_chi, RTRIM(c.area_name) AS area_name, RTRIM(c.area_chi) AS area_chi, geo_x, geo_y
        FROM district AS b, district_area AS c, address_detail AS a
        LEFT OUTER JOIN elderly_home_table AS d
            ON (a.record_id = d.eh_address_id)
        LEFT OUTER JOIN address_detail2 AS e
            ON (a.record_id = e.record_id)
        WHERE a.record_id = par_record_id AND a.district_code = b.district_code AND b.district_area = c.area_code;
		return next p_refcur;
END;
$function$
;


ALTER FUNCTION "cpi_get_address_detail" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
