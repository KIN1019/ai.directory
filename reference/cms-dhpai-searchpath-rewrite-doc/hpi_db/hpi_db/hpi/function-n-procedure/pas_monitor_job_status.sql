-- DROP PROCEDURE hpi.pas_monitor_job_status(in varchar, in varchar, inout varchar, inout varchar, in varchar, inout refcursor);

CREATE OR REPLACE PROCEDURE hpi.pas_monitor_job_status(IN par_in_info_type character varying, IN par_in_hosp_code character varying, INOUT par_red_alert character varying, INOUT par_red_alert_info character varying, IN par_in_debug_mode character varying, INOUT p_refcur refcursor)
 LANGUAGE plpgsql
AS $procedure$
/* JOB_STATUS/DNL_STATUS/UP_STATUS/REP_STATUS/EAP_INFO/ */
DECLARE
    var_hosp VARCHAR(6);
    var_chk_start_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_dnl_record_handled VARCHAR(2);
    var_last_dnl_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_chk_start_dtm_str VARCHAR(28);
    var_last_dnl_dtm_str VARCHAR(28);
    var_record_count INTEGER;
    var_patient_last_update_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_hospital_code VARCHAR(6);
    var_download_system_datetime TIMESTAMP WITHOUT TIME ZONE;
    var_hkid VARCHAR(24);
    var_patient_key VARCHAR(16);
    var_error_code INTEGER;
    var_error_msg VARCHAR(255);
    var_update_hospital VARCHAR(6);
    var_update_by VARCHAR(24);
    var_update_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_txn_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_txn_type VARCHAR(6);
    var_txn_hkid VARCHAR(24);
    var_txn_pky VARCHAR(16);
    var_txn_upd_hosp VARCHAR(6);
    var_txn_upd_by VARCHAR(24);
    var_txn_upd_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_txn_source_system_dtm TIMESTAMP WITHOUT TIME ZONE;
    var_txn_source_sys VARCHAR(10);
	sql$rowcount int;
	
	dnl_csr CURSOR FOR
    SELECT
        hospital_code, download_system_datetime, hkid, patient_key, error_code, error_msg, update_hospital, update_by, update_dtm
        FROM dnl_exception
        WHERE hospital_code = var_hosp AND download_system_datetime > var_chk_start_dtm AND error_code <> 7013 AND error_code <> 7016 AND error_code <> 1002 AND error_code <> 5004 AND error_code <> 6002 AND error_code <> 8002 AND error_code <> 2003 AND error_code <> 13002 AND error_code <> 200006 AND error_code <> 6009;

begin
	CREATE TEMPORARY TABLE  t$dnl_exception(
		dnl_record_handled		  VARCHAR(2) null,
		-- dnl_exception (created by cpi_download process) ----------------
		hospital_code            VARCHAR(6) not null,
		download_system_datetime TIMESTAMP WITHOUT TIME ZONE not null,
		hkid                     VARCHAR(24) not null,
		patient_key              VARCHAR(16) not null,
		error_code               INTEGER not null,
		error_msg                varchar(255) not null,
		update_hospital          VARCHAR(6) not null,
		update_by                VARCHAR(24) not null,
		update_dtm               TIMESTAMP WITHOUT TIME ZONE not null,
		-- cpi_transaction records (created by 'DNL' system) ----------------
		txn_dtm                  TIMESTAMP WITHOUT TIME ZONE null,
		txn_type                 VARCHAR(6) null,
		txn_hkid                 VARCHAR(24) null,
		txn_pky                  VARCHAR(18) null,
		txn_upd_hosp             VARCHAR(6) null,
		txn_upd_by               VARCHAR(24) null,
		txn_upd_dtm              TIMESTAMP WITHOUT TIME ZONE null,
		txn_source_system_dtm    TIMESTAMP WITHOUT TIME ZONE null,
		txn_source_sys           VARCHAR(10) null -- DNL only
	);
	create unique index t$dnl_exception_idx on t$dnl_exception (hospital_code,update_dtm);
	
	
	SELECT
        hospital_code
        INTO var_hosp
        FROM hospital;
    SELECT
        - 7 * INTERVAL '1 day' + localtimestamp::TIMESTAMP
        INTO var_chk_start_dtm;
    /* --select varchk_start_dtm = dateadd(day,-30,getdate()) */
    SELECT
        last_download_system_datetime
        INTO var_last_dnl_dtm
        FROM download_control_pg
        WHERE hospital_code = var_hosp;
    /* ------------------------------------------------------------------------------ */
    SELECT
        CONCAT(to_char(var_chk_start_dtm, 'YYYYMMDD'), ' ', to_char(var_chk_start_dtm, 'hh:mm:ss'))
        INTO var_chk_start_dtm_str;
    SELECT
        CONCAT(to_char(var_last_dnl_dtm, 'YYYYMMDD'), ' ', to_char(var_last_dnl_dtm, 'hh:mm:ss'))
        INTO var_last_dnl_dtm_str;
	OPEN dnl_csr;
	FETCH dnl_csr INTO var_hospital_code, var_download_system_datetime, var_hkid, var_patient_key, var_error_code, var_error_msg, var_update_hospital, var_update_by, var_update_dtm;
		
	GET DIAGNOSTICS sql$rowcount = ROW_COUNT;

	WHILE sql$rowcount = 0 loop
		BEGIN
			SELECT
				NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
				INTO var_hospital_code, var_download_system_datetime, var_hkid, var_patient_key, var_error_code, var_error_msg, var_update_hospital, var_update_by, var_update_dtm;
			
	
			SELECT
				transaction_datetime,
				/* WHEN the dnl_excption handled */
				transaction_type, hkid, patient_key, update_hospital,
				/* Must SAME as dnl_exption.update_hospital */
				update_by,
				/* Must SAME as dnl_exption.update_by */
				update_datetime,
				/* WHEN the dnl_excption handled */
				source_system_dtm,
				/* Must SAME as dnl_exption.download_system_datetime */
				source_system
				INTO var_txn_dtm, var_txn_type, var_txn_hkid, var_txn_pky, var_txn_upd_hosp, var_txn_upd_by, var_txn_upd_dtm, var_txn_source_system_dtm, var_txn_source_sys
				FROM cpi_transaction
				WHERE hospital_code = var_hospital_code AND transaction_datetime >= var_chk_start_dtm AND source_system = 'DNL' AND
				/* Records created by "DNL" system -- */
				upload_status = 'N' AND
				/* Records created by "DNL" system -- */
				
				/* -------------------------------------- */
				hkid = var_hkid AND update_by = var_update_by AND update_hospital = var_update_hospital AND
				/* --and source_system_dtm = vardownload_system_datetime  -- To fix:  extra Msec will be added if Duplicate Record found for cpi_transaction -- */
				source_system_dtm >= - 1 * INTERVAL '1 minute' + var_download_system_datetime::TIMESTAMP AND source_system_dtm <= 1 * INTERVAL '1 minute' + var_download_system_datetime::TIMESTAMP;
				
			IF var_txn_dtm IS NOT NULL THEN
				SELECT
					'Y'
					INTO var_dnl_record_handled;
			ELSE
				BEGIN
					/* ---------------------------------------------------------------------------------------- */
					/* 3.2) [7016]-"Patient has been updated after transaction, patient update is rejected!" */
					
					/* ---------------------------------------------------------------------------------------- */
					SELECT
						update_dtm
						INTO var_patient_last_update_dtm
						FROM cpi_patient
						WHERE patient_key = var_patient_key;
	
					IF (var_patient_last_update_dtm >= var_download_system_datetime) AND var_error_code = 7015 THEN
						SELECT
							'S'
							INTO var_dnl_record_handled;
					/* NO need to handle the [DNL Exception Record ] */
					ELSE
						BEGIN
							/* ---------------------------------------------------------------------------------------- */
							/* 3.3) Auto-Retry for 7015/200023 Error */
							/* 7015  : Fail to insert cpi_transaction for patient update! */
							/* 200023: Fail to insert Event_log, tx update is rejected! */
							
							/* ---------------------------------------------------------------------------------------- */
							IF var_error_code = 7015 OR var_error_code = 20023 THEN
								BEGIN
									/* ------------------------------------------------------------------------------ */
									/* 3.3.1). Auto trigger DNL process for 7015 err   -- */
									
									/* ------------------------------------------------------------------------------ */
									CALL cpi_download(var_return_code, var_hospital_code, var_download_system_datetime);
									/* ------------------------------------------------------------------------------ */
									/* 3.3.2). Check the DNL Exception record handled or NOT  -- */
									
									/* ------------------------------------------------------------------------------ */
									SELECT
										transaction_datetime,
										/* WHEN the dnl_excption handled */
										transaction_type, hkid, patient_key, update_hospital,
										/* Must SAME as dnl_exption.update_hospital */
										update_by,
										/* Must SAME as dnl_exption.update_by */
										update_datetime,
										/* WHEN the dnl_excption handled */
										source_system_dtm,
										/* Must SAME as dnl_exption.download_system_datetime */
										source_system
										INTO var_txn_dtm, var_txn_type, var_txn_hkid, var_txn_pky, var_txn_upd_hosp, var_txn_upd_by, var_txn_upd_dtm, var_txn_source_system_dtm, var_txn_source_sys
										FROM cpi_transaction
										WHERE hospital_code = var_hospital_code AND
										/* --and transaction_datetime >= varchk_start_dtm */
										transaction_datetime >= - 5 * INTERVAL '1 minute' + localtimestamp::TIMESTAMP AND source_system = 'DNL' AND
										/* Records created by "DNL" system -- */
										upload_status = 'N' AND
										/* Records created by "DNL" system -- */
										
										/* -------------------------------------- */
										hkid = var_hkid AND update_by = var_update_by AND update_hospital = var_update_hospital AND
										/* --and source_system_dtm = vardownload_system_datetime  -- To fix:  extra Msec will be added if Duplicate Record found for cpi_transaction -- */
										source_system_dtm >= - 1 * INTERVAL '1 minute' + var_download_system_datetime::TIMESTAMP AND source_system_dtm <= 1 * INTERVAL '1 minute' + var_download_system_datetime::TIMESTAMP;
									IF var_txn_dtm IS NOT NULL THEN
										SELECT
											'A'
											INTO var_dnl_record_handled;
									END if;
									/* DNL records handled Automatically */

								end;
							END if;
							/* 3.3). -- */
						end;
					END if;
					/* 3.2). -- */

				end;
			END if;
			insert into t$dnl_exception(dnl_record_handled,hospital_code,download_system_datetime,hkid,patient_key,error_code,error_msg,update_hospital,update_by,update_dtm,
					txn_dtm ,txn_type,txn_hkid,txn_pky ,txn_upd_hosp,txn_upd_by,txn_upd_dtm ,txn_source_system_dtm,txn_source_sys)
			values (var_dnl_record_handled,var_hospital_code,var_download_system_datetime,var_hkid,var_patient_key,var_error_code,var_error_msg,var_update_hospital,var_update_by,var_update_dtm,
					var_txn_dtm ,var_txn_type,var_txn_hkid,var_txn_pky ,var_txn_upd_hosp,var_txn_upd_by  ,var_txn_upd_dtm ,var_txn_source_system_dtm,var_txn_source_sys);
			
			SELECT NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
	        INTO var_hospital_code, var_download_system_datetime, var_hkid, var_patient_key, var_error_code, var_error_msg, var_update_hospital, var_update_by, var_update_dtm;
			
			SELECT 'N', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
	        INTO var_dnl_record_handled, var_txn_dtm, var_txn_type, var_txn_hkid, var_txn_pky, var_txn_upd_hosp, var_txn_upd_by, var_txn_upd_dtm, var_txn_source_system_dtm, var_txn_source_sys;
			
			FETCH dnl_csr INTO var_hospital_code, var_download_system_datetime, var_hkid, var_patient_key, var_error_code, var_error_msg, var_update_hospital, var_update_by, var_update_dtm;

			GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
		end;
	end loop;
	
	IF par_in_debug_mode = 'Y' THEN
        /* ------------------------------------------------ */
        /* A). Retrive all DNL Exception Records with handleing information */
        
        /* ------------------------------------------------ */
        OPEN p_refcur FOR
        SELECT
            dnl_record_handled, hospital_code, download_system_datetime, hkid, /* patient_key, */ error_code, error_msg, update_hospital, update_by, update_dtm, txn_dtm, txn_type, txn_hkid, txn_pky, txn_upd_hosp, txn_upd_by, txn_upd_dtm, txn_source_system_dtm, txn_source_sys
            FROM t$dnl_exception
            /* --where dnl_record_handled ='N' */
            ORDER BY dnl_record_handled NULLS FIRST, hospital_code NULLS FIRST, download_system_datetime NULLS FIRST;
    ELSE
        BEGIN
            /* ------------------------------------------------ */
            /* B). Retrive all un-hanlded DNL Exception Records */
            
            /* ------------------------------------------------ */
            SELECT
                COUNT(1)
                INTO var_record_count
                FROM t$dnl_exception
                WHERE dnl_record_handled = 'N';

            IF var_record_count >= 1 THEN
                BEGIN
                    /* ---------------------------------------------------------------------------------- */
                    SELECT
                        'Y'
                        INTO par_red_alert;
                    SELECT
                        CONCAT('[', var_hosp, ' Last_dnl_dtm[', var_last_dnl_dtm_str, '] ==> Total un-handled DNL records: [',
                        CASE CAST (var_record_count AS VARCHAR)
                            WHEN '' THEN ' '
                            ELSE CAST (var_record_count AS VARCHAR)
                        END, '] found since [', var_chk_start_dtm_str, ']')
                        INTO par_red_alert_info;
                    /* -------------------------------------------------------------------------------- */
                    OPEN p_refcur FOR
                    SELECT
                        'Warning ' AS alert, hospital_code AS hosp, CONCAT(' ') AS dnl_sys_dtm, hkid AS hkid, update_hospital AS upd_hosp, error_code AS err_code, error_msg AS err_msg
                        FROM t$dnl_exception
                        WHERE dnl_record_handled = 'N'
                        ORDER BY hospital_code NULLS FIRST, download_system_datetime NULLS FIRST;
                    /* -------------------------------------------------------------------------------- */
                END;
            ELSE
                BEGIN
                    SELECT
                        'N'
                        INTO par_red_alert;
                    SELECT
                        CONCAT('[', var_hosp, '].Last_dnl_dtm[', var_last_dnl_dtm_str, '] ==> NO Un-handled DNL records found since [', var_chk_start_dtm_str, ']')
                        INTO par_red_alert_info;
                END;
            END IF;
        END;
    END IF;
    /* ------------------------------------------------------- */
    DROP TABLE t$dnl_exception;

END;
$procedure$
;

;ALTER PROCEDURE "pas_monitor_job_status" OWNER TO "HPI_SCHEMA_OWNER_ROLE";