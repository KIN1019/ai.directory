-- DROP FUNCTION hasp_enq_pbrc_os_overriding(varchar, varchar, varchar, timestamp, timestamp);

CREATE OR REPLACE FUNCTION hasp_enq_pbrc_os_overriding(par_input_hospital_code character varying, par_input_hkid character varying DEFAULT NULL::character varying, par_input_case_no character varying DEFAULT NULL::character varying, par_input_from_date timestamp without time zone DEFAULT NULL::timestamp without time zone, par_input_to_date timestamp without time zone DEFAULT NULL::timestamp without time zone)
 RETURNS TABLE(hospital_code character varying, hkid character varying, name character varying, txn_type character varying, pay_code character varying, os_amt numeric, overriding_reason character varying, case_no character varying, adm_dtm timestamp without time zone, source_ind character varying, source_code character varying, ward_code character varying, ward_class character varying, spec_code character varying, eis_code character varying, action_code_type character varying, action_code character varying, term_id character varying, update_by character varying, update_dtm timestamp without time zone, source_system character varying, remark character varying)
 LANGUAGE plpgsql
AS $function$
BEGIN
    IF par_input_hospital_code IS NULL THEN
        RETURN QUERY SELECT NULL::VARCHAR(6),
                            NULL::VARCHAR(24),
                            NULL::VARCHAR(96),
                            NULL::VARCHAR(6),
                            NULL::VARCHAR(6),
                            NULL::NUMERIC,
                            NULL::VARCHAR(510),
                            NULL::VARCHAR(24),
                            NULL::TIMESTAMP,
                            NULL::VARCHAR(2),
                            NULL::VARCHAR(6),
                            NULL::VARCHAR(8),
                            NULL::VARCHAR(2),
                            NULL::VARCHAR(8),
                            NULL::VARCHAR(6),
                            NULL::VARCHAR(10),
                            NULL::VARCHAR(6),
                            NULL::VARCHAR(24),
                            NULL::VARCHAR(24),
                            NULL::TIMESTAMP,
                            NULL::VARCHAR(16),
                            NULL::VARCHAR(510);
        RETURN;
    END IF;

    IF par_input_hkid IS NOT NULL THEN
        RETURN QUERY
            SELECT l.hospital_code,
                   l.hkid,
                   p.name,
                   txn_type,
                   pay_code,
                   os_amt,
                   overriding_reason,
                   case_no,
                   adm_dtm,
                   source_ind,
                   source_code,
                   ward_code,
                   ward_class,
                   spec_code,
                   eis_code,
                   action_code_type,
                   action_code,
                   term_id,
                   update_by,
                   update_dtm,
                   source_system,
                   remark
            FROM pbrc_os_overriding_log l
                     JOIN pmi p ON l.hkid = p.hkid
            WHERE l.hospital_code = par_input_hospital_code
              AND l.hkid = par_input_hkid
            ORDER BY update_dtm, case_no, adm_dtm;
    ELSEIF par_input_case_no IS NOT NULL THEN
        RETURN QUERY
            SELECT l.hospital_code,
                   l.hkid,
                   p.name,
                   txn_type,
                   pay_code,
                   os_amt,
                   overriding_reason,
                   case_no,
                   adm_dtm,
                   source_ind,
                   source_code,
                   ward_code,
                   ward_class,
                   spec_code,
                   eis_code,
                   action_code_type,
                   action_code,
                   term_id,
                   update_by,
                   update_dtm,
                   source_system,
                   remark
            FROM pbrc_os_overriding_log l
                     JOIN pmi p ON l.hkid = p.hkid
            WHERE l.hospital_code = par_input_hospital_code
              AND case_no = par_input_case_no
            ORDER BY update_dtm, adm_dtm;
    ELSE
        IF par_input_to_date IS NOT NULL THEN
            par_input_to_date := par_input_to_date + INTERVAL '1 day';
        END IF;

        RETURN QUERY
            SELECT l.hospital_code,
                   l.hkid,
                   p.name,
                   l.txn_type,
                   l.pay_code,
                   l.os_amt,
                   l.overriding_reason,
                   l.case_no,
                   l.adm_dtm,
                   l.source_ind,
                   l.source_code,
                   l.ward_code,
                   l.ward_class,
                   l.spec_code,
                   l.eis_code,
                   l.action_code_type,
                   l.action_code,
                   l.term_id,
                   l.update_by,
                   l.update_dtm,
                   l.source_system,
                   l.remark
            FROM pbrc_os_overriding_log l
                     JOIN pmi p ON l.hkid = p.hkid
            WHERE l.hospital_code = par_input_hospital_code
              AND l.update_dtm >= COALESCE(par_input_from_date, CURRENT_TIMESTAMP)
              AND l.update_dtm < COALESCE(par_input_to_date, CURRENT_TIMESTAMP)
            ORDER BY l.update_dtm NULLS FIRST, l.adm_dtm NULLS FIRST;
    END IF;

    RETURN;
END;
$function$
;

;ALTER FUNCTION "hasp_enq_pbrc_os_overriding" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
