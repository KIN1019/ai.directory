-- DROP PROCEDURE cpi_get_hkpmi_major_key(inout int4, in varchar, inout varchar, inout varchar, inout varchar, inout timestamp, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout timestamp, inout varchar, inout varchar);

CREATE OR REPLACE PROCEDURE cpi_get_hkpmi_major_key(INOUT pas_return_code integer, IN par_hkid character varying, INOUT par_prk character varying, INOUT par_name character varying, INOUT par_sex character varying, INOUT par_dob timestamp without time zone, INOUT par_exact_dob character varying, INOUT par_ccc_1 character varying, INOUT par_ccc_2 character varying, INOUT par_ccc_3 character varying, INOUT par_ccc_4 character varying, INOUT par_ccc_5 character varying, INOUT par_ccc_6 character varying, INOUT par_update_by character varying, INOUT par_src_system character varying, INOUT par_update_dtm timestamp without time zone, INOUT par_hosp_code character varying, INOUT par_document_flag character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_return_code INTEGER;
    var_error INTEGER;
    var_error_detail VARCHAR(255);
    var_error_msg VARCHAR(255);
    var_rpc_call VARCHAR(360);
    var_hkpmi_srvr VARCHAR(300);
    var_pgm_name VARCHAR(30);
    var_hkpmi_down_flag VARCHAR(1);
    var_local_hosp VARCHAR(3);
    sql$rowcount BIGINT;
   v_message text;
  dblink_sql  text;
begin
	SET search_path TO hpi, public; 
    SELECT
        hkpmi_server
        INTO var_hkpmi_srvr
        FROM hkpmi_control;
    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

    IF sql$rowcount != 1 THEN
        BEGIN
            /* print "Fail to retrieve Gateway information! Retrieve PMI record is rejected!" */
            pas_return_code := 14001;
            RETURN;
        END;
    END IF;
    /* ----------20120105 Check HKPMI down Flag-------------------- */
    SELECT
        'N'
        INTO var_hkpmi_down_flag;
    SELECT
        hospital_code
        INTO var_local_hosp
        FROM hospital;
    SELECT
        appl_ctl_text_value
        INTO var_hkpmi_down_flag
        FROM pas_appl_control
        WHERE hospital_code = var_local_hosp AND appl_name = 'IPAS' AND appl_ctl_type = 'HKPMI_SP1_DOWN';

    IF var_hkpmi_down_flag = 'Y' THEN
        BEGIN
            SELECT
                NULL
                INTO var_hkpmi_srvr;
            CALL cpi_get_rpc_server(pas_return_code, 'HKPMI_READ_ONLY_SVR', var_hkpmi_srvr);

            IF var_hkpmi_srvr IS NULL THEN
                BEGIN
                    pas_return_code := 14002;
                    RETURN;
                END;
            END IF;
        END;
    END IF;
    /* ------------------------------------------------ */
   
	-- replace_dblink_by_fdw
   	CALL hkpmi.hkpmi_get_major_key(var_return_code, par_hkid, par_prk, par_name, par_sex, par_dob, par_exact_dob, 
   			par_ccc_1, par_ccc_2, par_ccc_3, par_ccc_4, par_ccc_5, par_ccc_6, par_update_by, par_src_system, par_update_dtm, par_hosp_code, par_document_flag) ;
	SET search_path TO hpi,public;
	raise notice 'cpi_get_hkpmi_major_key hkpmi.hkpmi_get_major_key var_return_code=%,par_hkid-%',var_return_code,par_hkid;
    IF var_return_code != 0 or var_return_code is null THEN
        BEGIN
            /* print "RPC call failure, Retrieve PMI record is rejected!" */
            pas_return_code := 14002;
            RETURN;
        END;
    END IF;
    /* select @prk, @name, @sex, @dob, @exact_dob, @ccc_1, @ccc_2, @ccc_3, @ccc_4, */
    /* @ccc_5, @ccc_6, @update_by, @src_system, @update_dtm, @hosp_code, @document_flag */
    pas_return_code := 0;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "cpi_get_hkpmi_major_key" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
