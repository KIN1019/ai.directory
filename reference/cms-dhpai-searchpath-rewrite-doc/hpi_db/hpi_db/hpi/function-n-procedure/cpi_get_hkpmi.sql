-- DROP PROCEDURE hpi.cpi_get_hkpmi(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, inout timestamp, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout int4, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout int4, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout timestamp, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar, inout varchar);

CREATE OR REPLACE PROCEDURE hpi.cpi_get_hkpmi(INOUT pas_return_code integer, IN par_hospital_code character varying, IN par_hkid character varying, IN par_local_saved character varying, IN par_source_system character varying, IN par_retrieve_by character varying, INOUT par_pmi_dob timestamp without time zone, INOUT par_pmi_exact_dob_flag character varying, INOUT par_pmi_mrn character varying, INOUT par_patient_name character varying, INOUT par_sex character varying, INOUT par_ccc_1 character varying, INOUT par_ccc_2 character varying, INOUT par_ccc_3 character varying, INOUT par_ccc_4 character varying, INOUT par_ccc_5 character varying, INOUT par_ccc_6 character varying, INOUT par_marital_status character varying, INOUT par_race_code character varying, INOUT par_other_doc_no character varying, INOUT par_building character varying, INOUT par_floor character varying, INOUT par_room character varying, INOUT par_block character varying, INOUT par_pmi_district character varying, INOUT par_home_phone_no character varying, INOUT par_death_ind character varying, INOUT par_patient_key character varying, INOUT par_card_holder integer, INOUT par_nok_building character varying, INOUT par_nok_room character varying, INOUT par_nok_floor character varying, INOUT par_nok_block character varying, INOUT par_nok_district character varying, INOUT par_nok_home_phone character varying, INOUT par_nok_other_phone_1 character varying, INOUT par_nok_other_phone_ext_1 character varying, INOUT par_nok_hkid character varying, INOUT par_nok_name character varying, INOUT par_nok_relation character varying, INOUT par_religion character varying, INOUT par_access_code integer, INOUT par_chi_name character varying, INOUT par_office_phone character varying, INOUT par_office_phone_ext character varying, INOUT par_other_phone character varying, INOUT par_other_phone_ext character varying, INOUT par_death_date timestamp without time zone, INOUT par_death_diagnosis character varying, INOUT par_death_external_cause character varying, INOUT par_patient_type character varying, INOUT par_nok_office_phone character varying, INOUT par_nok_office_phone_ext character varying, INOUT par_hkic_symbol character varying DEFAULT NULL::character varying)
 LANGUAGE plpgsql
AS $procedure$
/* ** added by Winnie Lau ** */DECLARE
    var_return_code INTEGER;
    var_error INTEGER;
    var_error_detail VARCHAR(255);
    var_transaction_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_death_indicator VARCHAR(4);
    var_error_msg VARCHAR(255);
    var_rpc_call VARCHAR(60);
    var_hkpmi_srvr VARCHAR(100);
    var_pgm_name VARCHAR(30);
    var_old_access_code INTEGER;
    var_hex INTEGER;
    var_opas_access_code INTEGER;
    var_hkpmi_down_flag VARCHAR(1);
    var_local_hosp VARCHAR(3);
    sql$rowcount BIGINT;
    
BEGIN

   /* SELECT
        hkpmi_server
        INTO var_hkpmi_srvr
        FROM hkpmi_control;
    GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
	raise notice 'cpi_get_hkpmi-var_hkpmi_srvr=%',var_hkpmi_srvr;
    IF sql$rowcount != 1 THEN
        BEGIN
            /* print "Fail to retrieve Gateway information! Retrieve PMI record is rejected!" */
            pas_return_code := 14001;
            RETURN;
        END;
    END IF;*/
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
  
    IF var_hkpmi_down_flag = 'Y' AND par_local_saved = 'N' THEN
        /* ---- ONLY avaiable for ReadOnly hkpmi */
        begin
	     
            SELECT
                NULL
                INTO var_hkpmi_srvr;
            CALL cpi_get_rpc_server(var_return_code,'HKPMI_READ_ONLY_SVR', var_hkpmi_srvr);

            IF var_hkpmi_srvr IS NULL THEN
                BEGIN
                    pas_return_code := 14002;
                    RETURN;
                END;
            END IF;
        END;
    END IF;
 
    IF var_hkpmi_down_flag = 'Y' AND par_local_saved = 'Y' THEN
        /* ---- ONLY avaiable for ReadOnly hkpmi */
        BEGIN
            pas_return_code := 14002;
            RETURN;
        END;
    END IF;
    /* ------------------------------------------------ */


    /* --select @rpc_call = rtrim(@gateway_id) + "..." + rtrim(@cics_id) */
    /* --select @rpc_call = rtrim(@hkpmi_srvr) + "..." + rtrim(@pgm_name) */
	CALL hkpmi.hkpmi_r_pmi_parm_1(var_return_code, par_hospital_code, par_hkid, 'P'::VARCHAR, 
	par_patient_name, par_sex, par_ccc_1, par_ccc_2, par_ccc_3, par_ccc_4, par_ccc_5, par_ccc_6, 
	par_pmi_dob, par_pmi_exact_dob_flag, par_marital_status, par_race_code, par_other_doc_no, par_pmi_mrn, par_building, par_room, par_floor,
	par_block, par_pmi_district, par_religion, par_home_phone_no, var_death_indicator, par_patient_key, par_nok_name, par_nok_hkid, par_nok_building,
	par_nok_room, par_nok_floor, par_nok_block, par_nok_district, par_nok_home_phone, par_nok_other_phone_1, par_nok_other_phone_ext_1, par_nok_relation,
	par_access_code, par_chi_name, par_office_phone, par_office_phone_ext, par_other_phone, par_other_phone_ext, par_death_date, par_death_diagnosis,
	par_death_external_cause, par_patient_type, par_card_holder, par_nok_office_phone, par_nok_office_phone_ext, par_local_saved, par_source_system, par_retrieve_by, par_hkic_symbol
		) ;
	SET search_path TO hpi,public;
	    
    IF var_return_code != 0 THEN
        BEGIN
            /* print "RPC call failure, Retrieve PMI record is rejected!" */
            pas_return_code := 14002;
            RETURN;
        END;
    END IF;

    IF par_pmi_dob IS NULL THEN
        SELECT
            'Y'
            INTO par_pmi_exact_dob_flag;
    END IF;
    /*
    if substring(@pmi_data,104,08) = space(8)
    begin
       select @pmi_mrn = null
    end
    else
    begin
       select @pmi_mrn = substring(@pmi_data,104,08)
    end
    */
    IF par_pmi_mrn = REPEAT('', 8) THEN

        SELECT
            NULL into par_pmi_mrn;
    END IF;

    IF par_religion = REPEAT('', 3) THEN
        SELECT
            NULL
            INTO par_religion;
    END IF;
    /* select @nok_name = ltrim(rtrim(substring(@nok_data,1,48))) */
    IF (LTRIM(RTRIM(par_nok_name)) = '') THEN
        SELECT
            NULL
            INTO par_nok_name;
    END IF;
    /* --select @nok_relation = substring(@nok_data,146,02) /*NOK relation code*/ */
    IF (par_nok_name IS NOT NULL) AND (par_nok_relation IS NULL) THEN
        SELECT
            'OT'
            INTO par_nok_relation;
    END IF;

    SELECT
        timestamp_convert(localtimestamp)
        INTO var_transaction_datetime;

    IF par_pmi_district = REPEAT('', 5) THEN
        SELECT
            NULL
            INTO par_pmi_district;
    END IF;

    IF (par_room != REPEAT('', 05) OR par_floor != REPEAT('', 02) OR par_block != REPEAT('', 02) OR par_building != REPEAT('', 47)) AND NOT EXISTS (SELECT
        *
        FROM district
        WHERE district_code = par_pmi_district) THEN
        BEGIN
            SELECT
                'UNK'
                INTO par_pmi_district;
        END;
    END IF;
    /*
    if substring(@nok_data,117,05) = space(5)
    begin
       select @nok_district = null
    end
    else
    begin
       select @nok_district = substring(@nok_data,117,05)
    end
    */
    IF par_nok_district = REPEAT('', 5) THEN
        SELECT
            NULL
            INTO par_nok_district;
    END IF;

    IF (par_nok_room != REPEAT('', 05) OR par_nok_floor != REPEAT('', 02) OR par_nok_block != REPEAT('', 02) OR par_nok_building != REPEAT('', 47)) AND NOT EXISTS (SELECT
        *
        FROM district
        WHERE district_code = par_nok_district) THEN
        BEGIN
            SELECT
                'UNK'
                INTO par_nok_district;
        END;
    END IF;
    /* --	if @access_code_int & 1 = 0    /* patient is confidential */ */
    SELECT
        par_access_code
        INTO var_old_access_code;

    IF par_access_code & 1 = 0 THEN /* patient is confidential */
        BEGIN
            /* get integer which bit 0,15,16,17 is off */
            CALL cpi_get_int_by_bin(var_return_code,'NYYYYYYYYYNNNYYNNNYYYYYYYYYYYYY', par_access_code);
            /* @access_code_int output */
        END;
    ELSE
        BEGIN
            /* get integer which all bit is on */
            CALL cpi_get_int_by_bin(var_return_code,'YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY', par_access_code);
            /* @access_code_int output */
        END;
    END IF;
    /* set bits (19 - 26) for OPAS from downloaded access code */
    CALL cpi_get_int_by_bin(var_return_code,'NNNNNNNNNNNNNNNNNNNYYYYYYYYNNNN', var_hex);
    SELECT
        var_old_access_code & var_hex
        INTO var_opas_access_code;
    /* turn off OPAS bits (19 to 26) from patient access code */
    CALL cpi_get_int_by_bin(var_return_code,'YYYYYYYYYYYYYYYYYYYNNNNNNNNYYYY', var_hex);
    SELECT
        par_access_code & var_hex
        INTO par_access_code;
    /* set downloaded OPAS bits (19 to 26) to patient access code */
    SELECT
        par_access_code | var_opas_access_code
        INTO par_access_code;
    /* --	select @access_code = convert(VARCHAR(10), @access_code_int) */
    /* Added by Stephen CHAN */
    IF par_ccc_1 = REPEAT('', 05) THEN
        SELECT
            NULL
            INTO par_ccc_1;
    END IF;

    IF par_ccc_2 = REPEAT('', 05) THEN
        SELECT
            NULL
            INTO par_ccc_2;
    END IF;

    IF par_ccc_3 = REPEAT('', 05) THEN
        SELECT
            NULL
            INTO par_ccc_3;
    END IF;

    IF par_ccc_4 = REPEAT('', 05) THEN
        SELECT
            NULL
            INTO par_ccc_4;
    END IF;

    IF par_ccc_5 = REPEAT('', 05) THEN
        SELECT
            NULL
            INTO par_ccc_5;
    END IF;

    IF par_ccc_6 = REPEAT('', 05) THEN
        SELECT
            NULL
            INTO par_ccc_6;
    END IF;

    IF var_death_indicator IS NULL THEN
        SELECT
            'N'
            INTO par_death_ind;
    ELSE
        SELECT
            'Y'
            INTO par_death_ind;
    END IF;
    /* --	exec	@pas_return_code = 	cpi_insert_new_patient */
    /* --				@hospital_code, */
    /* --				@hkid, */
    /* --				@patient_name, */
    /* --				@sex, */
    /* @pmi_dob, */
    /* @pmi_exact_dob_flag, */

    /* --				@ccc_1, */

    /* --				@ccc_2, */

    /* --				@ccc_3, */

    /* --				@ccc_4, */

    /* --				@ccc_5, */

    /* --				@ccc_6, */
    /* @chi_name,          /* GL 19981103 */ */
    /* --				NULL,			        --chi_name */

    /* --				@marital_status, */

    /* --				@race_code, */

    /* --				@other_doc_no, */

    /* --				NULL,			        /* reference */ */
    /* NULL,               --Medical_record_number */

    /* --				NULL,	              /* Remark */ */

    /* --				@building, */

    /* --				@room, */

    /* --				@floor, */

    /* --				@block, */
    /* @pmi_district,       /* District_code */ */
    /* @religion,           /* Religion_code */ */

    /* --				@home_phone_no, */
    /* @office_phone,       /* GL 19981103 */ */
    /* @office_phone_ext,   /* GL 19981103 */ */
    /* @other_phone,        /* GL 19981103 */ */
    /* @other_phone_ext,    /* GL 19981103 */ */

    /*
    NULL,              	--other_phone_no_1
    NULL,	               --other_phone_ext_1
    NULL,	               --other_phone_no_2
    NULL,                --other_phone_ext_2
    */

    /* --				@death_ind, */

    /* --			   @death_date,         /* GL 19981103 */ */
    /* --				NULL,                --death_date */

    /* --				NULL,                /* death_code */ */

    /* --				@card_holder,        /* card_holder */ */

    /* --				@patient_key, */

    /* --				NULL,                /* priority */ */
    /* @nok_name, */
    /* @nok_hkid, */

    /* --				@nok_relation, */

    /* --				@nok_building, */

    /* --				@nok_room, */

    /* --				@nok_floor, */

    /* --				@nok_block, */
    /* @nok_district, */

    /* --				@nok_home_phone, */
    /* @nok_office_phone,     /* GL 19981103 */ */
    /* @nok_office_phone_ext, /* GL 19981103 */ */

    /* --				@nok_other_phone_1, */

    /* --				@nok_other_phone_ext_1, */

    /*
    NULL,                --nok_other_phone_no_2
    NULL,		            --nok_other_phone_ext_2
    */

    /* --				"010", */
    /* --				@access_code_int, */

    /* --				@access_code, */

    /* --				0,                   /* security */ */

    /* --				@transaction_datetime, */

    /* --				@hospital_code,	   /* update hospital */ */

    /* --				"HKPMI",	            /* update by */ */

    /* --				@transaction_datetime, */

    /* --				"HKPMI"		         /* source system */ */

    /* -- */

    /* --		if (@pas_return_code != 0) */

    /* --		begin */

    /* --			return @pas_return_code */

    /* --		end */
    pas_return_code := 0;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "cpi_get_hkpmi" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
