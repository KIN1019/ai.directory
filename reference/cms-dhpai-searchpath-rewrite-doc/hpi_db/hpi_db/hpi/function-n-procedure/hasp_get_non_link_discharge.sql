-- DROP PROCEDURE hasp_get_non_link_discharge(inout int4, in varchar, in varchar, in varchar, in timestamp, in timestamp, inout refcursor);

CREATE OR REPLACE PROCEDURE hasp_get_non_link_discharge(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_transaction_type character varying, IN par_discharge_code character varying, IN par_report_from_date timestamp without time zone, IN par_report_to_date timestamp without time zone, INOUT p_refcur refcursor DEFAULT NULL::refcursor)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_return                   INTEGER;
    var_pas_return_code          INTEGER;
    var_case                     VARCHAR(12);
    var_dsch_dtm                 TIMESTAMP WITHOUT TIME ZONE;
    var_dsch_code                VARCHAR(1);
    var_dest                     VARCHAR(5);
    var_ward                     VARCHAR(4);
    var_spec                     VARCHAR(4);
    var_hkid                     VARCHAR(12);
    var_transaction_type_pattern VARCHAR(12);
    var_hkpmi_srvr               TEXT;
    var_pgm VARCHAR(80);
    var_hkpmi_down_flag VARCHAR(1);
    var_local_hosp VARCHAR(3);
    var_rpc_call VARCHAR(800);
    csr CURSOR FOR
        SELECT Case_no, From_ward_code, From_specialty_code
        FROM Transaction_log
        WHERE Transaction_type IN ('130', '134', '330', '334', '339')
          AND (var_transaction_type_pattern IS NULL OR Transaction_type LIKE var_transaction_type_pattern)
          AND (par_discharge_code IS NULL OR SUBSTRING(Transaction_type, 3, 1) = par_discharge_code)
          AND Transaction_datetime >= par_report_from_date
          AND Transaction_datetime < par_report_to_date
          AND Cancel_flag IS NULL
          AND Hospital_code = par_hospital_code;
BEGIN

    DROP TABLE IF EXISTS t$temp_discharge;
    CREATE TEMPORARY TABLE t$temp_discharge
    (
        hkid               VARCHAR(12),
        case_no            VARCHAR(12),
        discharge_datetime TIMESTAMP WITHOUT TIME ZONE,
        discharge_code     VARCHAR(1),
        destination        VARCHAR(5),
        ward_code          VARCHAR(4),
        specialty_code     VARCHAR(4)
    );
    CREATE UNIQUE INDEX temp_index ON t$temp_discharge
        (hkid, case_no);

    IF par_report_from_date IS NULL THEN
        par_report_from_date := CURRENT_DATE - INTERVAL '1 day';
    END IF;
    IF par_report_to_date IS NULL THEN
        par_report_to_date := par_report_from_date + INTERVAL '1 day';
    END IF;
    par_report_to_date := par_report_to_date + INTERVAL '1 day';

    IF par_transaction_type IS NULL THEN
        var_transaction_type_pattern := NULL;
    ELSE
        IF par_transaction_type = '100' THEN
            var_transaction_type_pattern := '13%';
        ELSIF par_transaction_type = '300' THEN
            var_transaction_type_pattern := '33%';
        ELSE
            var_transaction_type_pattern := par_transaction_type;
        END IF;
    END IF;

    OPEN csr;

    LOOP
        FETCH csr INTO var_case, var_ward, var_spec;

        EXIT WHEN NOT FOUND;

        SELECT Discharge_datetime, Discharge_code, Destination_code, HKID
        INTO var_dsch_dtm, var_dsch_code, var_dest, var_hkid
        FROM Case_view
        WHERE Case_no = var_case
          AND Hospital_code = par_hospital_code;
         
        /*SELECT RTRIM(hkpmi_server) INTO var_hkpmi_srvr FROM hkpmi_control;*/
       
		BEGIN
	         /*perform public.dblink_connect('hkpmi'::text, var_hkpmi_srvr);
	        RAISE NOTICE 'dblink connection established';
	   
	        SELECT '.hkpmi_get_linked_case'
	            INTO var_pgm; /* ---Default DB =download for HKPMI2 !!! */
	        SELECT
	            concat(schema_name, var_pgm)  
	        INTO var_rpc_call
	        FROM hkpmi_control;
	
	        BEGIN
	            SELECT * FROM public.dblink('hkpmi'::text, 'call ' 
	            || var_rpc_call || '(' 
	            || case when var_return is null then 0 else 0 end || ','
	            || case when var_hkid is null then 'null::bpchar' else concat('''', var_hkid, '''::bpchar') end || ','
	            || case when par_hospital_code is null then 'null::bpchar' else concat('''', par_hospital_code, '''::bpchar') end || ','
	            || case when var_case is null then 'null::bpchar' else concat('''', var_case, '''::bpchar') end || ','
	            || 'null::bpchar,'
	            || 'null::bpchar,'
	            || 'null::bpchar)'
	            ) as t1(var_return INTEGER) into var_return;
	            perform public.dblink_disconnect('hkpmi'::text);
	        exception
	            when others then
	            perform public.dblink_disconnect('hkpmi'::text);
	           RAISE NOTICE 'dblink error: %', SQLERRM;
	        end;*/
			
			-- replace dblink by fdw
			SET search_path TO hkpmi,public;
	       	CALL hkpmi.hkpmi_get_linked_case(var_return, var_hkid, par_hospital_code, var_case, NULL::VARCHAR, NULL::VARCHAR, NULL::VARCHAR); 
	       	SET search_path TO hpi,public;
--	       	raise notice 'var_return:%',var_return;
	
	        IF var_return = 0 THEN
	            INSERT INTO t$temp_discharge (hkid, case_no, discharge_datetime, discharge_code, destination,
	                                          ward_code, specialty_code)
	            VALUES (var_hkid, var_case, var_dsch_dtm, var_dsch_code, var_dest, var_ward, var_spec);
	        END IF;
	        EXCEPTION
	        WHEN OTHERS THEN
	            RAISE NOTICE 'CALL hkpmi.hkpmi_get_linked_case failed: %', SQLERRM;
	    END;
    END LOOP;

    CLOSE csr;

    CLUSTER t$temp_discharge USING temp_index;

    OPEN p_refcur FOR
        SELECT hkid,
               case_no,
               discharge_datetime,
               discharge_code,
               destination,
               ward_code,
               specialty_code
        FROM t$temp_discharge 
        ORDER BY hkid NULLS FIRST , case_no NULLS FIRST;

    pas_return_code := 0;
    RETURN;

END;
$procedure$
;

;ALTER PROCEDURE "hasp_get_non_link_discharge" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
