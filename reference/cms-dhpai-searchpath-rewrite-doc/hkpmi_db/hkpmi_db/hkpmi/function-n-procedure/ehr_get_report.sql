-- DROP FUNCTION hkpmi.ehr_get_report(bpchar, date);

CREATE OR REPLACE FUNCTION hkpmi.ehr_get_report(par_report_no varchar, par_report_dtm date)
 RETURNS SETOF refcursor
 LANGUAGE plpgsql
AS $function$
declare p_refcur refcursor;
BEGIN
    IF (par_report_no < '1' OR par_report_no > '6') THEN
        BEGIN
            
            RETURN;
        END;
    END IF;

    IF (par_report_dtm IS NULL) THEN
        BEGIN
            
            RETURN;
        END;
    END IF;

    IF (par_report_no = '1') THEN
        BEGIN
            OPEN p_refcur FOR
            SELECT
                rpt_f1, rpt_f2, rpt_f3, rpt_f4
                FROM ehr_report
                WHERE report_dtm = par_report_dtm AND report_id = 1
                ORDER BY CAST (rpt_f5 AS INTEGER) NULLS FIRST;
	return next p_refcur;
        END;
    END IF;

    IF (par_report_no = '2') THEN
        BEGIN
            OPEN p_refcur FOR
            SELECT
                rpt_f1, rpt_f2, rpt_f3, rpt_f4, rpt_f5, rpt_f6, rpt_f7, rpt_f8, rpt_f9, rpt_f10, rpt_f11, rpt_f12, rpt_f13, rpt_f14, rpt_f15, rpt_f16, rpt_f17, rpt_f18
                FROM ehr_report
                WHERE report_dtm = par_report_dtm AND report_id = 2;
	return next p_refcur;        
END;
    END IF;

    IF (par_report_no = '3') THEN
        BEGIN
            OPEN p_refcur FOR
            SELECT
                rpt_f1, rpt_f2, rpt_f3, rpt_f4, rpt_f5, rpt_f6, rpt_f7, rpt_f8, rpt_f9, rpt_f10, rpt_f11, rpt_f12, rpt_f13, rpt_f14, rpt_f15, rpt_f16, rpt_f17, rpt_f18, rpt_f19
                FROM ehr_report
                WHERE report_dtm = par_report_dtm AND report_id = 3;
	return next p_refcur;        
END;
    END IF;

    IF (par_report_no = '4') THEN
        BEGIN
            OPEN p_refcur FOR
            SELECT
                rpt_f1, rpt_f2, rpt_f3, rpt_f4, rpt_f5, rpt_f6, rpt_f7, rpt_f8, rpt_f9, rpt_f10, rpt_f11, rpt_f12, rpt_f13, rpt_f14, rpt_f15, rpt_f16, rpt_f17, rpt_f18, rpt_f19, rpt_f20, rpt_f21, rpt_f22, rpt_f23, rpt_f24, rpt_f25, rpt_f26, rpt_f27, rpt_f28, rpt_f29, rpt_f30
                FROM ehr_report
                WHERE report_dtm = par_report_dtm AND report_id = 4;
        	return next p_refcur;
END;
    END IF;

    IF (par_report_no = '5') THEN
        BEGIN
            OPEN p_refcur FOR
            SELECT
                rpt_f1, rpt_f2, rpt_f3, rpt_f4, rpt_f5, rpt_f6, rpt_f7, rpt_f8, rpt_f9, rpt_f10, rpt_f11, rpt_f12, rpt_f13, rpt_f14, rpt_f15, rpt_f16, rpt_f17, rpt_f18, rpt_f19
                FROM ehr_report
                WHERE report_dtm = par_report_dtm AND report_id = 5;
	return next p_refcur;        
END;
    END IF;

    IF (par_report_no = '6') THEN
        BEGIN
            OPEN p_refcur FOR
            SELECT
                rpt_f1, rpt_f2, rpt_f3, rpt_f4, rpt_f5, rpt_f6, rpt_f7, rpt_f8, rpt_f9, rpt_f10, rpt_f11, rpt_f12, rpt_f13, rpt_f14, rpt_f15, rpt_f16, rpt_f17, rpt_f18, rpt_f19, rpt_f20, rpt_f21, rpt_f22, rpt_f23
                FROM ehr_report
                WHERE report_id = 6;
	return next p_refcur;        
END;
    END IF;
    
    RETURN;
END;
$function$
;


ALTER FUNCTION "ehr_get_report" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

