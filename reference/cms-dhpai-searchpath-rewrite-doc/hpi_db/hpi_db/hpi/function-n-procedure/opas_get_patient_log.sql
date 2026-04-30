-- DROP FUNCTION hpi.opas_get_patient_log(varchar, varchar, varchar, timestamp, varchar);

CREATE OR REPLACE FUNCTION hpi.opas_get_patient_log(par_patient_key character varying, par_hospital character varying, par_tran_type character varying, par_update_dtm timestamp without time zone, par_type character varying)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
DECLARE
	    p_refcur refcursor;
/* ***** Object:  Stored Procedure opas_get_patient_log    Script Date: 11/10/96 15:34:25 ***** */
/* *type 1 for petient_log* */
/* *type 2 for patient_log_detail, type 'CO'* */
/* *type 3 for patient_log_detail, type 'CH'* */
/* *type 4 for patient_log_detail, type 'CK'* */
begin
	SET search_path TO hpi, public; 
    IF par_type = '1' THEN
        BEGIN
            OPEN p_refcur FOR
            SELECT
                CAST (0 AS INTEGER) c1, CAST (timestamp_convert(update_dtm) AS TIMESTAMP WITHOUT TIME ZONE) update_dtm, CAST ('CK' AS VARCHAR(2)), CAST ('' AS VARCHAR(12)) c2
                FROM cpi_patient_key_changed
                WHERE patient_key = par_patient_key
            UNION ALL
            SELECT
                CAST (0 AS INTEGER) c1, CAST (timestamp_convert(update_dtm) AS TIMESTAMP WITHOUT TIME ZONE) update_dtm, CAST ('CO' AS VARCHAR(2)), CAST ('' AS VARCHAR(12)) c2
                FROM cpi_patient_other_changed
                WHERE patient_key = par_patient_key
            UNION ALL
            SELECT
                CAST (0 AS INTEGER) c1, CAST (timestamp_convert(update_dtm) AS TIMESTAMP WITHOUT TIME ZONE) update_dtm, CAST ('CH' AS VARCHAR(2)), CAST ('' AS VARCHAR(12)) c2
                FROM cpi_patient_hosp_mrn_changed
                WHERE patient_key = par_patient_key AND hospital_code = par_hospital;
			RETURN NEXT p_refcur;
        END;
    ELSE
        IF par_type = '2' THEN
            BEGIN
                OPEN p_refcur FOR
                SELECT
                    CAST ('CO' AS VARCHAR(2)) c1, CAST ('' AS VARCHAR(12)) c2, CAST ('' AS VARCHAR(12)) c3, CAST ('' AS VARCHAR(48)) c4, CAST ('' AS VARCHAR(1)) c5,
                    CAST ('' AS VARCHAR(5)) c6, CAST ('' AS VARCHAR(5)) c7, CAST ('' AS VARCHAR(5)) c8, CAST ('' AS VARCHAR(5)) c9, CAST ('' AS VARCHAR(5)) c10,
                    CAST ('' AS VARCHAR(5)) c11, CAST ('' AS VARCHAR(12)) c12, timestamp_convert(update_dtm) update_dtm_1, CAST ('' AS VARCHAR(1)) c13,
                    CAST (COALESCE(marital_status, '') AS VARCHAR(2)) marital_status, CAST ('' AS VARCHAR(2)) c14, CAST (COALESCE(other_doc_no, '') AS VARCHAR(24)) other_doc_no,
                    CAST ('' AS VARCHAR(20)), CAST ('' AS VARCHAR(8)) c15, CAST ('' AS VARCHAR(12)) c16, CAST (COALESCE(building, '') AS VARCHAR(94)) building, CAST (COALESCE(room, '') AS VARCHAR(10)) room,
                    CAST (COALESCE(floor, '') AS VARCHAR(4)) floor, CAST (COALESCE(block, '') AS VARCHAR(4)) block, CAST (COALESCE(district, '') AS VARCHAR(5)) district,
                    CAST (COALESCE(religion, '') AS VARCHAR(3)) religion, CAST (COALESCE(phone1, '') AS VARCHAR(20)) phone1, CAST (COALESCE(phone2, '') AS VARCHAR(20)) phone2, 
                    CAST (COALESCE(address_indicator, '') AS VARCHAR(8)) address_indicator, CAST (COALESCE(mobile_phone, '') AS VARCHAR(20)) mobile_phone,
                    CAST (COALESCE(sms_language, '') AS VARCHAR(8)) sms_language, CAST ('' AS VARCHAR(3)) c17, CAST ('' AS VARCHAR(1)) c18, timestamp_convert(update_dtm) update_dtm_2,
                    CAST ('' AS VARCHAR(1)) c19, CAST (COALESCE(update_by, '') AS VARCHAR(16)) update_by, timestamp_convert(update_dtm) update_dtm_3
                    FROM cpi_patient_other_changed
                    WHERE patient_key = par_patient_key AND timestamp_convert(update_dtm) = par_update_dtm;
				RETURN NEXT p_refcur;
            END;
        ELSE
            IF par_type = '3' THEN
                BEGIN
                    OPEN p_refcur FOR
                    SELECT
                        CAST ('CH' AS VARCHAR(2)) c1, CAST ('' AS VARCHAR(12)) c2, CAST ('' AS VARCHAR(12)) c3, CAST ('' AS VARCHAR(48)) c4, CAST ('' AS VARCHAR(1)) c5, 
                        CAST ('' AS VARCHAR(5)) c6, CAST ('' AS VARCHAR(5)) c7, CAST ('' AS VARCHAR(5)) c8, CAST ('' AS VARCHAR(5)) c9, CAST ('' AS VARCHAR(5)) c10, CAST ('' AS VARCHAR(5)) c11, 
                        CAST ('' AS VARCHAR(12)) c12, timestamp_convert(update_dtm) update_dtm_1, CAST ('' AS VARCHAR(1)) c13, CAST ('' AS VARCHAR(1)) c14, 
                        CAST ('' AS VARCHAR(2)) c15, CAST ('' AS VARCHAR(12)) c16, CAST ('' AS VARCHAR(20)) c17, COALESCE(mrn, '') mrn, 
                        CAST ('' AS VARCHAR(12)) c18, CAST ('' AS VARCHAR(47)) c19, CAST ('' AS VARCHAR(5)) c20, CAST ('' AS VARCHAR(2)) c21,
                        CAST ('' AS VARCHAR(2)) c22, CAST ('' AS VARCHAR(5)) c23, CAST ('' AS VARCHAR(3)) c24, CAST ('' AS VARCHAR(10)) c25, 
                        CAST ('' AS VARCHAR(10)) c26, CAST ('' AS VARCHAR(4)) c27, CAST ('' AS VARCHAR(10)) c28, CAST ('' AS VARCHAR(4)) c29, 
                        CAST ('' AS VARCHAR(3)) c30, CAST ('' AS VARCHAR(1)) c31, timestamp_convert(update_dtm) update_dtm_2, CAST ('' AS VARCHAR(1)) c32, CAST (update_by AS VARCHAR(8)) update_by, timestamp_convert(update_dtm) update_dtm_3
                        FROM cpi_patient_hosp_mrn_changed
                        WHERE patient_key = par_patient_key AND timestamp_convert(update_dtm) = par_update_dtm AND hospital_code = par_hospital;
					RETURN NEXT p_refcur;
			   END;
            ELSE
                IF par_type = '4' THEN
                    BEGIN
                        OPEN p_refcur FOR
                        SELECT
                            CAST ('CK' AS VARCHAR(2)) c1, CAST (COALESCE(hkid, '') AS VARCHAR(24)) hkid, CAST ('' AS VARCHAR(24)) c2, CAST (COALESCE(patient_name, '') AS VARCHAR(96)) patient_name, CAST (COALESCE(sex, '') AS VARCHAR(2)) sex,
                            CAST (COALESCE(cccode1, '') AS VARCHAR(10)) cccode1, CAST (COALESCE(cccode2, '') AS VARCHAR(10)) cccode2, CAST (COALESCE(cccode3, '') AS VARCHAR(10)) cccode3,
                            CAST (COALESCE(cccode4, '') AS VARCHAR(10)) cccode4, CAST (COALESCE(cccode5, '') AS VARCHAR(10)) cccode5, CAST (COALESCE(cccode6, '') AS VARCHAR(5)) cccode6,
                            CAST (COALESCE(chi_name, '') AS VARCHAR(24)) chi_name, dob dob_1, CAST ('' AS VARCHAR(1)) c3, CAST ('' AS VARCHAR(1)) c4, CAST ('' AS VARCHAR(2)) c5, 
                            CAST ('' AS VARCHAR(12)) c6, CAST ('' AS VARCHAR(20)) c7, CAST ('' AS VARCHAR(8)) c8, CAST ('' AS VARCHAR(12)) c9, CAST ('' AS VARCHAR(47)) c10,
                            CAST ('' AS VARCHAR(5)) c11, CAST ('' AS VARCHAR(2)) c12, CAST ('' AS VARCHAR(2)) c13, CAST ('' AS VARCHAR(5)) c14, CAST ('' AS VARCHAR(3)) c15,
                            CAST ('' AS VARCHAR(10)) c16, CAST ('' AS VARCHAR(10)) c17, CAST ('' AS VARCHAR(4)) c18, CAST ('' AS VARCHAR(10)) c19, CAST ('' AS VARCHAR(4)) c20,
                            CAST ('' AS VARCHAR(3)) c21, CAST ('' AS VARCHAR(1)) c22, dob dob_2, CAST ('' AS VARCHAR(1)) c23, CAST (COALESCE(update_by, '') AS VARCHAR(16)) update_by, timestamp_convert(update_dtm) update_dtm_1
                            FROM cpi_patient_key_changed
                            WHERE patient_key = par_patient_key AND timestamp_convert(update_dtm) = par_update_dtm;
						RETURN NEXT p_refcur;
					END;
                END IF;
            END IF;
        END IF;
    END IF;
END;
$function$
;

;ALTER FUNCTION "opas_get_patient_log" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
