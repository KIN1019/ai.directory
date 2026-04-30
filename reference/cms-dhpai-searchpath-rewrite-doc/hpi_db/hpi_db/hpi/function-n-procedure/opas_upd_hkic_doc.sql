-- DROP PROCEDURE hpi.opas_upd_hkic_doc(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, inout int4, inout varchar);

CREATE OR REPLACE PROCEDURE hpi.opas_upd_hkic_doc(INOUT pas_return_code integer, IN par_hospital character varying, IN par_hkid character varying, IN par_document_code character varying, IN par_hkic_symbol character varying, IN par_source_system character varying, IN par_update_by character varying, IN par_update_dt timestamp without time zone, INOUT par_return_code integer DEFAULT 0, INOUT par_return_msg character varying DEFAULT ''::character varying)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    var_patient_key VARCHAR(8);
    /* ---------original patient demo ------- */
    var_org_hkic_symbol VARCHAR(1);
    var_org_doc_code VARCHAR(1);
    var_org_other_doc_no VARCHAR(12);
    var_org_patient_name VARCHAR(48);
    var_org_exact_dob VARCHAR(1);
    var_org_sex VARCHAR(1);
    var_org_home_phone VARCHAR(10);
    var_org_marital_code VARCHAR(1);
    var_org_nok_name VARCHAR(48);
    var_org_nok_hk_id VARCHAR(12);
    var_org_nok_relationship VARCHAR(2);
    var_org_nok_building VARCHAR(47);
    var_org_nok_room VARCHAR(5);
    var_org_nok_floor VARCHAR(2);
    var_org_nok_block VARCHAR(2);
    var_org_nok_district_code VARCHAR(5);
    var_org_nok_home_phone VARCHAR(10);
    var_org_ccc_1 VARCHAR(05);
    var_org_ccc_2 VARCHAR(05);
    var_org_ccc_3 VARCHAR(05);
    var_org_ccc_4 VARCHAR(05);
    var_org_ccc_5 VARCHAR(05);
    var_org_ccc_6 VARCHAR(05);
    var_org_chi_name VARCHAR(12);
    var_org_race_code VARCHAR(02);
    var_org_dob TIMESTAMP WITHOUT TIME ZONE;
    var_org_remark VARCHAR(255);
    var_org_reference VARCHAR(20);
    var_org_mrn VARCHAR(08);
    var_org_room VARCHAR(05);
    var_org_floor VARCHAR(02);
    var_org_block VARCHAR(02);
    var_org_building VARCHAR(47);
    var_org_district_code VARCHAR(05);
    var_org_religion_code VARCHAR(03);
    var_org_priority INTEGER;
    var_org_nok_other_phone_no_1 VARCHAR(10);
    var_org_nok_other_phone_ext_1 VARCHAR(04);
    var_org_nok_other_phone_no_2 VARCHAR(10);
    var_org_nok_other_phone_ext_2 VARCHAR(04);
    var_org_other_phone_no_1 VARCHAR(10);
    var_org_other_phone_ext_1 VARCHAR(4);
    var_org_other_phone_no_2 VARCHAR(10);
    var_org_other_phone_ext_2 VARCHAR(4);
    var_org_death_ind VARCHAR(1);
    var_org_death_date TIMESTAMP WITHOUT TIME ZONE;
    var_org_death_code VARCHAR(4);
    var_org_card_holder INTEGER;
    var_org_access_code INTEGER;
    var_org_security INTEGER;
    var_begin_tran VARCHAR(1);
    var_row_count INTEGER;
    var_local_hosp VARCHAR(3);
    var_system_datetime TIMESTAMP WITHOUT TIME ZONE;
    sql$rowcount BIGINT;

BEGIN
    <<rtn_normal>>
    BEGIN
        <<rtn_err>>
        begin
	        SET search_path TO hpi, public;
            /* ----------------------------------------------------------------------------------- */
            /* ---A). Init/validation for calling this SP */
            /* ----------------------------------------------------------------------------------- */
            SELECT
                'N'
                INTO var_begin_tran;
            SELECT
                hospital_code
                INTO var_local_hosp
                FROM hospital;

            IF RTRIM(LTRIM(par_document_code)) = NULL OR (RTRIM(LTRIM(par_document_code)) = '') THEN
                SELECT
                    NULL
                    INTO par_document_code;
            END IF;

            IF RTRIM(LTRIM(par_hkic_symbol)) = NULL OR (RTRIM(LTRIM(par_hkic_symbol)) = '') THEN
                SELECT
                    NULL
                    INTO par_hkic_symbol;
            END IF;
            /* ---A1). Reject if both hkic_sym/doc is null -- */
            IF par_document_code IS NULL AND par_hkic_symbol IS NULL THEN
                BEGIN
                    SELECT
                        - 1
                        INTO par_return_code;
                    SELECT
                        'both hkic_sym/doc_code is null, update rejected !'
                        INTO par_return_msg;
                    EXIT rtn_err;
                END;
            END IF;
            /* ---A2). Reject if sys not OPAS --- */
            IF par_source_system NOT IN ('OPAS', 'OPAS2') THEN
                BEGIN
                    SELECT
                        - 2
                        INTO par_return_code;
                    SELECT
                        'opas_upd_hkic_doc called by OPAS system ONLY !'
                        INTO par_return_msg;
                    EXIT rtn_err;
                END;
            END IF;
            /* A3). Reject if hospital code not matched */

            IF par_hospital <> var_local_hosp THEN
                BEGIN
                    SELECT
                        - 5
                        INTO par_return_code;
                    SELECT
                        'Hospital Code NOT matched !'
                        INTO par_return_msg;
                    EXIT rtn_err;
                END;
            END IF;

            IF NOT EXISTS (SELECT
                *
                FROM document_type
                WHERE document_code = par_document_code) OR par_document_code = 'Z' THEN
                /* --- OPAS system auto-gen doc code */
                BEGIN
                    SELECT
                        - 6
                        INTO par_return_code;
                    SELECT
                        'Invlid document_code !'
                        INTO par_return_msg;
                    EXIT rtn_err;
                END;
            END IF;

            IF NOT EXISTS (SELECT
                *
                FROM hkic_symbol_table
                WHERE hkic_symbol = par_hkic_symbol) THEN
                BEGIN
                    SELECT
                        - 7
                        INTO par_return_code;
                    SELECT
                        'Invlid hkic_symbol  !'
                        INTO par_return_msg;
                    EXIT rtn_err;
                END;
            END IF;
            /* ----------------------------------------------------------------------------------- */
            /* ---B). Retrive the patient orginal pdemo (include org.last doc code / org hkic_sym) */
            /* ----------------------------------------------------------------------------------- */
            SELECT
                patient_key, hkic_symbol,
                /* ---------------------------------- */
                patient_name, sex, dob, exact_dob_flag, cccode1, cccode2, cccode3, cccode4, cccode5, cccode6, chi_name, marital_status, race, other_doc_no, reference,
                /* --	@org_mrn,			---cpi_patient_hospital_data.mrn */
                /* --	@org_remark,		---cpi_patient_hospital_data.remark */
                building, room, floor, block, district, religion, phone1, phone2, address_indicator, mobile_phone, sms_language, death_indicator, death_date, death_code, card_holder,
                /* --	@patient_key,    ---@to_hkid prk -- */
                /* --	@org_priority,		---cpi_nok.priority -- */
                /* --	@org_nok_name, */
                /* --	@org_nok_hk_id, */
                /* --	@org_nok_relationship, */
                /* --	@org_nok_building, */
                /* --	@org_nok_room, */
                /* --	@org_nok_floor, */
                /* --	@org_nok_block, */
                /* --	@org_nok_district_code, */
                /* --	@org_nok_home_phone, */
                /* --	@org_nok_other_phone_no_1, */
                /* --	@org_nok_other_phone_ext_1, */
                /* --	@org_nok_other_phone_no_2, */
                /* --	@org_nok_other_phone_ext_2, */
                /* --	"030", */
                access_code, security
                INTO var_patient_key, var_org_hkic_symbol, var_org_patient_name, var_org_sex, var_org_dob, var_org_exact_dob, var_org_ccc_1, var_org_ccc_2, var_org_ccc_3, var_org_ccc_4, var_org_ccc_5, var_org_ccc_6, var_org_chi_name, var_org_marital_code, var_org_race_code, var_org_other_doc_no, var_org_reference, var_org_building, var_org_room, var_org_floor, var_org_block, var_org_district_code, var_org_religion_code, var_org_home_phone, var_org_other_phone_no_1, var_org_other_phone_ext_1, var_org_other_phone_no_2, var_org_other_phone_ext_2, var_org_death_ind, var_org_death_date, var_org_death_code, var_org_card_holder, var_org_access_code, var_org_security
                FROM cpi_patient
                WHERE hkid = par_hkid;
            /* --- B1). Patient Not Found ----- */
            GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
            var_row_count := sql$rowcount;

            IF var_row_count = 0 OR var_patient_key IS NULL THEN
                BEGIN
                    SELECT
                        - 3
                        INTO par_return_code;
                    SELECT
                        'Paitent NOT Found ! update rejected !'
                        INTO par_return_msg;
                    EXIT rtn_err;
                END;
            END IF;
            /* Org Last doc code - */
            SELECT
                doc_code
                INTO var_org_doc_code
                FROM patient_doc_info
                WHERE patient_key = var_patient_key;
            /* --Org MRN/remark -- */
            SELECT
                mrn, remark
                INTO var_org_mrn, var_org_remark
                FROM cpi_patient_hospital_data
                WHERE patient_key = var_patient_key AND hospital_code = par_hospital;
            /* ---Org NOK info. ---- */
            SELECT
                priority, nok_name, hkid, relationship, building, room, floor, block, district,phone1, phone2, address_indicator, mobile_phone, sms_language
                INTO var_org_priority, var_org_nok_name, var_org_nok_hk_id, var_org_nok_relationship, var_org_nok_building, var_org_nok_room, var_org_nok_floor, var_org_nok_block, var_org_nok_district_code, var_org_nok_home_phone, var_org_nok_other_phone_no_1, var_org_nok_other_phone_ext_1, var_org_nok_other_phone_no_2, var_org_nok_other_phone_ext_2
                FROM cpi_nok
                WHERE patient_key = var_patient_key AND major_nok = 'Y';
            /* ----------------------------------------------------------------------------------- */
            /* ---C). Validation on doc_code/hkic_sym change or NOT */
            /* ----------------------------------------------------------------------------------- */
            IF RTRIM(LTRIM(var_org_doc_code)) = NULL OR (RTRIM(LTRIM(var_org_doc_code)) = '') THEN
                SELECT
                    NULL
                    INTO var_org_doc_code;
            END IF;

            IF RTRIM(LTRIM(var_org_hkic_symbol)) = NULL OR (RTRIM(LTRIM(var_org_hkic_symbol)) = '') THEN
                SELECT
                    NULL
                    INTO var_org_hkic_symbol;
            END IF;

            IF COALESCE(par_document_code, '-') = COALESCE(var_org_doc_code, '-') AND /* --'-' NOT exists in document_type table ! -- */ COALESCE(par_hkic_symbol, 'NULL') = COALESCE(var_org_hkic_symbol, 'NULL') THEN /* ---'N' NOT exists in hkic_symbol table, */
                BEGIN
                    /* --select @return_code = -3 */
                    /* --select @return_msg  = "Nothing change" */
                    /* --goto RTN_ERR */
                    SELECT
                        0
                        INTO par_return_code;
                    EXIT rtn_normal;
                END;
            END IF;
            /* ----------------------------------------------------------------------------------- */
            /* ---D). Trigger cpi_patient_update if Doc_code/HKIC_symb changed from OPAS */
            /* ----------------------------------------------------------------------------------- */
            SELECT
                timestamp_convert(localtimestamp)
                INTO var_system_datetime;
            /*
            [3057 - Severity CRITICAL - PostgreSQL does not support SAVE TRAN cpi_pat_upd_txn command. Perform a manual conversion.]
            save transaction cpi_pat_upd_txn
            */
			<<cpi_pat_upd_txn>>
			begin
				SELECT
					'Y'
					INTO var_begin_tran;
				/* --20140721 : update the local replicated table(HKPMI.patient_doc_info -->cpi.patient_doc_info) directly -- */
				/* --if isnull(@document_code,'NULL') != isnull(@org_doc_code,'NULL') */
				IF COALESCE(par_document_code, '-') != COALESCE(var_org_doc_code, '-') THEN /* ---'-' NOT exists in document_type table ! -- */
					BEGIN
						/*UPDATE patient_doc_info
						SET doc_code = par_document_code
							WHERE patient_key = var_patient_key;*/
						
						IF EXISTS (SELECT 1 FROM patient_doc_info_op WHERE patient_key = var_patient_key)
					    THEN 
					    	UPDATE patient_doc_info_op
					        SET doc_code = par_document_code,upd_dtm = CLOCK_TIMESTAMP()
					        WHERE patient_key = var_patient_key;
					    ELSE 
					    	IF EXISTS (SELECT 1 FROM hkpmi.patient_doc_info_hkpmi WHERE patient_key = var_patient_key)
					    	THEN 
					    		INSERT INTO patient_doc_info_op SELECT * FROM hkpmi.patient_doc_info_hkpmi WHERE patient_key = var_patient_key;
					    		UPDATE patient_doc_info_op
					        	SET doc_code = par_document_code,upd_dtm = CLOCK_TIMESTAMP()
					        	WHERE patient_key = var_patient_key;
					    	END IF ;
					    END IF ;
					END;
				END IF;
				/* --20140721 -- */
				CALL cpi_patient_update(par_return_code,par_hospital, par_hkid,
				/* ----------------------- */
				var_org_patient_name, var_org_sex, var_org_dob, var_org_exact_dob, var_org_ccc_1, var_org_ccc_2, var_org_ccc_3, var_org_ccc_4, var_org_ccc_5, var_org_ccc_6, var_org_chi_name, var_org_marital_code, var_org_race_code, var_org_other_doc_no, var_org_reference, var_org_mrn, var_org_remark, var_org_building, var_org_room, var_org_floor, var_org_block, var_org_district_code, var_org_religion_code, var_org_home_phone, var_org_other_phone_no_1, var_org_other_phone_ext_1, var_org_other_phone_no_2, var_org_other_phone_ext_2, var_org_death_ind, var_org_death_date, var_org_death_code, var_org_card_holder, var_patient_key, var_org_priority, var_org_nok_name, var_org_nok_hk_id, var_org_nok_relationship, var_org_nok_building, var_org_nok_room, var_org_nok_floor, var_org_nok_block, var_org_nok_district_code, var_org_nok_home_phone, var_org_nok_other_phone_no_1, var_org_nok_other_phone_ext_1, var_org_nok_other_phone_no_2, var_org_nok_other_phone_ext_2, '030', /* ---transaction_type -- */ var_org_access_code, var_org_security,
				/* --------------------- */
				var_system_datetime, /* ---txn_dtm */ par_hospital, par_update_by, par_update_dt, par_source_system, par_document_code, /* ---input doc code */ par_hkic_symbol, /* ---input hkic_symbol */ NULL);
	
				/* --- @hkic_symbol_clear  --- ONLY allow in IPAS 'update pdemo' */
	
				IF par_return_code = 0 THEN
					BEGIN
						SELECT
							'Updated Success !'
							INTO par_return_msg;
						EXIT rtn_normal;
					END;
				ELSE
					BEGIN
						SELECT
							CONCAT('Updated Failed with cpi_patient_update return_code[',
							CASE CAST (par_return_code AS VARCHAR(8))
								WHEN '' THEN ''
								ELSE CAST (par_return_code AS VARCHAR(8))
							END, ']')
							INTO par_return_msg;
						SELECT
							- 4
							INTO par_return_code;
						RAISE EXCEPTION 'rollback';
					END;
				END IF;
				EXCEPTION WHEN OTHERS THEN
					BEGIN
						EXIT rtn_err;
					END;
			end;
        END;

        pas_return_code := par_return_code;
        RETURN;
    END;
	
    pas_return_code := 0;
    RETURN;
END;
$procedure$
;

;ALTER PROCEDURE "opas_upd_hkic_doc" OWNER TO "HPI_SCHEMA_OWNER_ROLE";