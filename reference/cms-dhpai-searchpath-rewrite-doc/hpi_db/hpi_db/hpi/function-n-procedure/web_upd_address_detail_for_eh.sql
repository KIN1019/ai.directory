-- DROP PROCEDURE hpi.web_upd_address_detail_for_eh(inout int4);

CREATE OR REPLACE PROCEDURE hpi.web_upd_address_detail_for_eh(INOUT pas_return_code integer)
 LANGUAGE plpgsql
AS $procedure$
/* --------No input parm----------------------------------------- */
DECLARE
    var_begin_tran VARCHAR(2);
    var_rowcount INTEGER;
    var_record_id INTEGER;
    var_upd_total INTEGER;
    var_working_table_row_count INTEGER;
    var_old_bldg_chi VARCHAR(100);
    var_old_bldg_eng VARCHAR(200);
    var_old_estate_chi VARCHAR(80);
    var_old_estate_eng VARCHAR(100);
    var_old_house_no VARCHAR(20);
    var_old_street_chi VARCHAR(50);
    var_old_street_eng VARCHAR(100);
    var_old_district_code VARCHAR(10);
    var_new_bldg_chi VARCHAR(100);
    var_new_bldg_eng VARCHAR(200);
    var_new_estate_chi VARCHAR(80);
    var_new_estate_eng VARCHAR(100);
    var_new_house_no VARCHAR(20);
    var_new_street_chi VARCHAR(50);
    var_new_street_eng VARCHAR(100);
    var_new_district_code VARCHAR(10);
    /* --return message */
    var_return_code INTEGER;
    var_error_msg VARCHAR(100);
    addr_csr CURSOR FOR
    SELECT
        record_id, old_bldg_chi, old_bldg_eng, old_estate_chi, old_estate_eng, old_house_no, old_street_chi, old_street_eng, old_district_code, new_bldg_chi, new_bldg_eng, new_estate_chi, new_estate_eng, new_house_no, new_street_chi, new_street_eng, new_district_code
        FROM temp_addr_detail_for_eh;
    upd_addr_csr CURSOR FOR
    SELECT
        record_id, old_bldg_chi, old_bldg_eng, old_estate_chi, old_estate_eng, old_house_no, old_street_chi, old_street_eng, old_district_code, new_bldg_chi, new_bldg_eng, new_estate_chi, new_estate_eng, new_house_no, new_street_chi, new_street_eng, new_district_code
        FROM temp_addr_detail_for_eh;
    sql$rowcount BIGINT;
BEGIN
    <<main_body>>
    BEGIN
        SELECT
            0
            INTO var_return_code;
        SELECT
            0
            INTO var_upd_total;
        SELECT
            COUNT(*)
            INTO var_working_table_row_count
            FROM temp_addr_detail_for_eh;
        /* Start Transaction */
        SELECT
            'Y'
            INTO var_begin_tran;
        /*
        [3014 - Severity CRITICAL - PostgreSQL doesn't support the @@TRANCOUNT function. Use suitable function or create user defined function.]
        if @@trancount = 0
        	begin
        		select @begin_tran = 'Y'
        		begin transaction
        	end
            else
            begin
        		select @begin_tran = 'S                                                                                                                                                                                                                                                                    '
        		save transaction web_upd_address_detail_for_eh
            end
        */ /* Adaptive Server has expanded all '*' elements in the following statement */
        /* -------------- */
        OPEN addr_csr;
        FETCH addr_csr INTO var_record_id, var_old_bldg_chi, var_old_bldg_eng, var_old_estate_chi, var_old_estate_eng, var_old_house_no, var_old_street_chi, var_old_street_eng, var_old_district_code, var_new_bldg_chi, var_new_bldg_eng, var_new_estate_chi, var_new_estate_eng, var_new_house_no, var_new_street_chi, var_new_street_eng, var_new_district_code;

        WHILE (CASE
            WHEN FOUND THEN 0
            WHEN NOT FOUND THEN 2
            ELSE 1
        END) = 0 LOOP
            IF (var_record_id < 5000001 OR var_record_id > 5999999) THEN
                BEGIN
                    SELECT
                        CONCAT('record_id ', var_record_id, ' is not within 5000001 - 5999999(range for elderly home), please verify again')
                        INTO var_error_msg;
                    SELECT
                        19999
                        INTO var_return_code;
                    pas_return_code := var_return_code;
                    EXIT main_body;
                END;
            ELSE
                IF (SELECT
                    COUNT(*)
                    FROM address_detail
                    WHERE record_id = var_record_id AND bldg_eng = var_old_bldg_eng AND estate_eng = var_old_estate_eng AND house_no = var_old_house_no AND street_eng = var_old_street_eng AND district_code = var_old_district_code) != 1 THEN
                    BEGIN
                        SELECT
                            29999
                            INTO var_return_code;
                        SELECT
                            CONCAT('The address for record_id ', var_record_id, ' does not match data in existing table, please verify again')
                            INTO var_error_msg;
                        pas_return_code := var_return_code;
                        EXIT main_body;
                    END;
                END IF;
            END IF;

            FETCH addr_csr INTO var_record_id, var_old_bldg_chi, var_old_bldg_eng, var_old_estate_chi, var_old_estate_eng, var_old_house_no, var_old_street_chi, var_old_street_eng, var_old_district_code, var_new_bldg_chi, var_new_bldg_eng, var_new_estate_chi, var_new_estate_eng, var_new_house_no, var_new_street_chi, var_new_street_eng, var_new_district_code;
        END LOOP;
        CLOSE addr_csr;
        /* -------------- */
        /* Adaptive Server has expanded all '*' elements in the following statement */
        OPEN upd_addr_csr;
        FETCH upd_addr_csr INTO var_record_id, var_old_bldg_chi, var_old_bldg_eng, var_old_estate_chi, var_old_estate_eng, var_old_house_no, var_old_street_chi, var_old_street_eng, var_old_district_code, var_new_bldg_chi, var_new_bldg_eng, var_new_estate_chi, var_new_estate_eng, var_new_house_no, var_new_street_chi, var_new_street_eng, var_new_district_code;

        WHILE (CASE
            WHEN FOUND THEN 0
            WHEN NOT FOUND THEN 2
            ELSE 1
        END) = 0 LOOP
            RAISE NOTICE 'Processing the record ID [%]', var_record_id;

            BEGIN
                UPDATE address_detail
                SET bldg_chi = var_new_bldg_chi, bldg_eng = var_new_bldg_eng, estate_chi = var_new_estate_chi, estate_eng = var_new_estate_eng, house_no = var_new_house_no, street_chi = var_new_street_chi, street_eng = var_new_street_eng, district_code = var_new_district_code
                    WHERE record_id = var_record_id AND bldg_eng = var_old_bldg_eng AND estate_eng = var_old_estate_eng AND house_no = var_old_house_no AND street_eng = var_old_street_eng AND district_code = var_old_district_code;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;
                IF var_rowcount <> 1 THEN
                    BEGIN
                        SELECT
                            39999
                            INTO var_return_code;
                        SELECT
                            CONCAT('Unexpected updated row count ',
                            CASE CAST (var_rowcount AS VARCHAR(5))
                                WHEN '' THEN ''
                                ELSE CAST (var_rowcount AS VARCHAR(5))
                            END, ' occurs (row count should be 1 normally in each update)')
                            INTO var_error_msg;

                        pas_return_code := var_return_code;
                        EXIT main_body;
                    END;
                END IF;
            EXCEPTION 
                WHEN others THEN
                    BEGIN
                        SELECT
                            39999
                            INTO var_return_code;
                        SELECT
                            CONCAT('Unexpected updated row count ',
                            CASE CAST (var_rowcount AS VARCHAR(5))
                                WHEN '' THEN ''
                                ELSE CAST (var_rowcount AS VARCHAR(5))
                            END, ' occurs (row count should be 1 normally in each update)')
                            INTO var_error_msg;
                        pas_return_code := var_return_code;
                        EXIT main_body;
                    END;
            END;

            SELECT
                var_upd_total + 1
                INTO var_upd_total;
            FETCH upd_addr_csr INTO var_record_id, var_old_bldg_chi, var_old_bldg_eng, var_old_estate_chi, var_old_estate_eng, var_old_house_no, var_old_street_chi, var_old_street_eng, var_old_district_code, var_new_bldg_chi, var_new_bldg_eng, var_new_estate_chi, var_new_estate_eng, var_new_house_no, var_new_street_chi, var_new_street_eng, var_new_district_code;
        END LOOP;
        CLOSE upd_addr_csr;
    END;

    IF var_return_code <> 0 THEN
        BEGIN
             RAISE EXCEPTION '%', var_error_msg USING ERRCODE := var_return_code;
        END;
    END IF;

    RAISE NOTICE 'Total row count in temp_addr_detail_for_eh: [%]', var_working_table_row_count;
    RAISE NOTICE 'Total record updated in address_detail: [%]', var_upd_total;

    IF var_upd_total = var_working_table_row_count THEN
        BEGIN
            RAISE NOTICE 'Row count matched.';
        END;
    ELSE
        BEGIN
            RAISE NOTICE 'Row count does not match, please verify again';
        END;
    END IF;

    pas_return_code := var_return_code;
END;
$procedure$
;