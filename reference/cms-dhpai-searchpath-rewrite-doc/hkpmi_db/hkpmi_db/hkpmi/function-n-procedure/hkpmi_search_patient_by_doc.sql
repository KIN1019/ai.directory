-- DROP PROCEDURE hkpmi_search_patient_by_doc(inout int4, in varchar, in varchar, in varchar, in int4, inout refcursor);

CREATE OR REPLACE PROCEDURE hkpmi_search_patient_by_doc(INOUT pas_return_code integer, IN par_doc_code character varying, IN par_doc_no character varying, IN par_source_system character varying, IN par_row_count integer DEFAULT 301, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
/* follow cpi..cpi_transaction */
DECLARE
    var_error_msg VARCHAR(255);
BEGIN
    /*
    [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT @row_count clause of SET statement is not supported. Perform a manual conversion.]
    set rowcount @row_count
    */
    /* ---------- Ensure the mandatory fields are not empty ---------- */
    IF par_doc_no IS NULL OR LENGTH(par_doc_no) = 0 THEN
        BEGIN
            SELECT 'Document number cannot be blank'
            INTO var_error_msg;
            RAISE EXCEPTION '%', var_error_msg USING ERRCODE = '999999';
            pas_return_code := 999999;
            RETURN;
        END;
    END IF;

    IF (LTRIM(RTRIM(par_source_system)) = '') OR (LTRIM(RTRIM(par_source_system)) IS NULL) THEN
        BEGIN
            SELECT 'Source system cannot be blank'
            INTO var_error_msg;
            RAISE EXCEPTION '%', var_error_msg USING ERRCODE = '999999';
            pas_return_code := 999999;
            RETURN;
        END;
    END IF;
    /*
    140828/Max Chan/Don't use "upper" or double-byte data will be altered:
    Original Chinese :=97=c0=90i=8c=b9
    After applying upper():=92=f2=e6=b8=8c=b9
    */
    /* --select @doc_no = upper(@doc_no) */
    /* ---------- Search patient by document type and code ---------- */
    IF par_doc_code IS NULL OR par_doc_code = '' THEN
        BEGIN
            /* -- if no input document code, search with all document code */
            OPEN p_refcur FOR
                SELECT p.hkid,
                       p.patient_name,
                       p.sex,
                       p.dob,
                       NULL,
                    /* not to return MRN */
                       p.phone1,
                       c1.unicode_int,
                       c2.unicode_int,
                       c3.unicode_int,
                       c4.unicode_int,
                       c5.unicode_int,
                       c6.unicode_int,
                       p.phone2,
                       p.address_indicator,
                       p.building,
                       p.district,
                       d.district_name,
                       pdi.doc_no,
                       dt.document_type,
                       p.patient_key
                FROM patient_doc_info AS pdi
                         LEFT OUTER JOIN patient AS p
                                         ON pdi.patient_key = p.patient_key
                         LEFT OUTER JOIN ccc_unicode AS c1
                                         ON SUBSTRING(p.cccode1, 1, 4) = c1.ccc_head AND
                                            SUBSTRING(p.cccode1, 5, 1) = c1.ccc_tail
                         LEFT OUTER JOIN ccc_unicode AS c2
                                         ON SUBSTRING(p.cccode2, 1, 4) = c2.ccc_head AND
                                            SUBSTRING(p.cccode2, 5, 1) = c2.ccc_tail
                         LEFT OUTER JOIN ccc_unicode AS c3
                                         ON SUBSTRING(p.cccode3, 1, 4) = c3.ccc_head AND
                                            SUBSTRING(p.cccode3, 5, 1) = c3.ccc_tail
                         LEFT OUTER JOIN ccc_unicode AS c4
                                         ON SUBSTRING(p.cccode4, 1, 4) = c4.ccc_head AND
                                            SUBSTRING(p.cccode4, 5, 1) = c4.ccc_tail
                         LEFT OUTER JOIN ccc_unicode AS c5
                                         ON SUBSTRING(p.cccode5, 1, 4) = c5.ccc_head AND
                                            SUBSTRING(p.cccode5, 5, 1) = c5.ccc_tail
                         LEFT OUTER JOIN ccc_unicode AS c6
                                         ON SUBSTRING(p.cccode6, 1, 4) = c6.ccc_head AND
                                            SUBSTRING(p.cccode6, 5, 1) = c6.ccc_tail
                         LEFT OUTER JOIN district AS d
                                         ON d.district_code = p.district
                         LEFT OUTER JOIN document_type AS dt
                                         ON dt.document_code = pdi.doc_code
                WHERE pdi.doc_no = par_doc_no
                /* --and p.hkid like 'U%' */
                ORDER BY p.patient_name COLLATE "C" NULLS FIRST, p.hkid COLLATE "C" NULLS FIRST
                limit par_row_count;
        END;
    ELSE
        BEGIN
            /*
            20140828/C/Victor/to cater the UID patients
            if document type is NC, format the other document number as HKID automatically
            */
            IF par_doc_code = 'F' THEN
                BEGIN
                    IF LENGTH(par_doc_no) = 8 THEN
                        BEGIN
                            SELECT CONCAT(' ', par_doc_no)
                            INTO par_doc_no;
                        END;
                    END IF;
                END;
            END IF;
            /*
            Advised by HI on 15/04/2014 by mail - to include all active document types for selection:
            - If AE selected, show all PMIs with 'AR' + 'AE' type
            - If AN selected, show all PMIs with 'AR' + 'AN' type
            - If BE selected, show all PMIs with 'BC' + 'BE' type
            - If BN selected, show all PMIs with 'BC' + 'BN' type
            */
            OPEN p_refcur FOR
                SELECT p.hkid,
                       p.patient_name,
                       p.sex,
                       p.dob,
                       NULL,
                    /* not to return MRN */
                       p.phone1,
                       c1.unicode_int,
                       c2.unicode_int,
                       c3.unicode_int,
                       c4.unicode_int,
                       c5.unicode_int,
                       c6.unicode_int,
                       p.phone2,
                       p.address_indicator,
                       p.building,
                       p.district,
                       d.district_name,
                       pdi.doc_no,
                       dt.document_type,
                       p.patient_key
                FROM patient_doc_info AS pdi
                         LEFT OUTER JOIN patient AS p
                                         ON pdi.patient_key = p.patient_key
                         LEFT OUTER JOIN ccc_unicode AS c1
                                         ON SUBSTRING(p.cccode1, 1, 4) = c1.ccc_head AND
                                            SUBSTRING(p.cccode1, 5, 1) = c1.ccc_tail
                         LEFT OUTER JOIN ccc_unicode AS c2
                                         ON SUBSTRING(p.cccode2, 1, 4) = c2.ccc_head AND
                                            SUBSTRING(p.cccode2, 5, 1) = c2.ccc_tail
                         LEFT OUTER JOIN ccc_unicode AS c3
                                         ON SUBSTRING(p.cccode3, 1, 4) = c3.ccc_head AND
                                            SUBSTRING(p.cccode3, 5, 1) = c3.ccc_tail
                         LEFT OUTER JOIN ccc_unicode AS c4
                                         ON SUBSTRING(p.cccode4, 1, 4) = c4.ccc_head AND
                                            SUBSTRING(p.cccode4, 5, 1) = c4.ccc_tail
                         LEFT OUTER JOIN ccc_unicode AS c5
                                         ON SUBSTRING(p.cccode5, 1, 4) = c5.ccc_head AND
                                            SUBSTRING(p.cccode5, 5, 1) = c5.ccc_tail
                         LEFT OUTER JOIN ccc_unicode AS c6
                                         ON SUBSTRING(p.cccode6, 1, 4) = c6.ccc_head AND
                                            SUBSTRING(p.cccode6, 5, 1) = c6.ccc_tail
                         LEFT OUTER JOIN district AS d
                                         ON d.district_code = p.district
                         LEFT OUTER JOIN document_type AS dt
                                         ON dt.document_code = pdi.doc_code
                WHERE pdi.doc_no = par_doc_no
                  AND
                    /* original input document code */
                    (pdi.doc_code = par_doc_code OR
                        /* additional document code */
                     pdi.doc_code =
                     CASE par_doc_code
                         WHEN 'O' THEN '2'
                         WHEN 'P' THEN '2'
                         WHEN 'Q' THEN '3'
                         WHEN 'R' THEN '3'
                         ELSE ''
                         END)
                /* --and p.hkid like 'U%' */
                ORDER BY p.patient_name COLLATE "C" NULLS FIRST, p.hkid COLLATE "C" NULLS FIRST
                limit par_row_count;
        END;
    END IF;
    /*
    [3069 - Severity CRITICAL - Automatic conversion of ROWCOUNT 0 clause of SET statement is not supported. Perform a manual conversion.]
    set rowcount 0
    */
    pas_return_code := 0;
    RETURN;
END;
$procedure$
;

ALTER PROCEDURE "hkpmi_search_patient_by_doc" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";

