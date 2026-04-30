-- DROP PROCEDURE hpi.hasp_insert_transaction_log(inout int4, in varchar, in timestamp, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in timestamp, in varchar, in timestamp, in varchar, in varchar, in timestamp);

CREATE OR REPLACE PROCEDURE hpi.hasp_insert_transaction_log(INOUT pas_return_code integer, IN par_hosp character varying, IN "par_System_datetime" timestamp without time zone, IN "par_Case_no" character varying, IN "par_From_ward_code" character varying, IN "par_From_treatment_location" character varying, IN "par_From_class" character varying, IN "par_From_bed" character varying, IN "par_From_specialty_code" character varying, IN "par_To_ward_code" character varying, IN "par_To_treatment_location" character varying, IN "par_To_class" character varying, IN "par_To_bed" character varying, IN "par_To_specialty_code" character varying, IN "par_Transaction_datetime" timestamp without time zone, IN "par_Transaction_type" character varying, IN "par_Post_datetime" timestamp without time zone, IN "par_User_ID" character varying, IN "par_Post_flag" character varying, IN "par_Prev_system_datetime" timestamp without time zone)
 LANGUAGE plpgsql
AS $procedure$
/* Return values   Meaning */

DECLARE
    var_error INTEGER;
    var_rowcount INTEGER;
    var_curdate TIMESTAMP WITHOUT TIME ZONE;
    var_t_date TIMESTAMP WITHOUT TIME ZONE;
    var_d_bed INTEGER;
    var_o_bed INTEGER;
    var_source_indicator VARCHAR(1);
    var_work_thru_ae INTEGER;
    var_t_type VARCHAR(03);
    var_w_ward_code VARCHAR(04);
    var_w_treatment_location VARCHAR(4);
    var_w_class VARCHAR(1);
    var_w_bed VARCHAR(5);
    var_w_specialty_code VARCHAR(4);
    var_f_ward_code VARCHAR(04);
    var_f_treatment_location VARCHAR(4);
    var_f_class VARCHAR(1);
    var_f_bed VARCHAR(5);
    var_f_specialty_code VARCHAR(4);
    var_t_ward_code VARCHAR(04);
    var_t_treatment_location VARCHAR(4);
    var_t_class VARCHAR(1);
    var_t_bed VARCHAR(5);
    var_t_specialty_code VARCHAR(4);
    var_t_post_flag VARCHAR(1);
    var_t_type2 VARCHAR(03);
    var_cancel_flag VARCHAR(01);
    sql$rowcount BIGINT;
begin
	RAISE notice 'par_Case_no=%', "par_Case_no";
    <<error>>
    BEGIN
        <<end_delete_transaction_log>>
        BEGIN
            /* begin transaction */
            /* Insert Transaction log */
            SELECT
                "par_System_datetime"
                INTO var_t_date;
            SELECT
                "par_Transaction_type"
                INTO var_t_type;
            SELECT
                "par_To_ward_code"
                INTO var_t_ward_code;
            SELECT
                "par_To_treatment_location"
                INTO var_t_treatment_location;
            SELECT
                "par_To_class"
                INTO var_t_class;
            SELECT
                "par_To_bed"
                INTO var_t_bed;
            SELECT
                "par_To_specialty_code"
                INTO var_t_specialty_code;
            SELECT
                "par_From_ward_code"
                INTO var_f_ward_code;
            SELECT
                "par_From_treatment_location"
                INTO var_f_treatment_location;
            SELECT
                "par_From_class"
                INTO var_f_class;
            SELECT
                "par_From_bed"
                INTO var_f_bed;
            SELECT
                "par_From_specialty_code"
                INTO var_f_specialty_code;
            SELECT
                NULL
                INTO var_cancel_flag;
            /*
            For cancellation tran.
            set post_flag = Y
            */
            /* Only type 120, 121 can have pass in parameter @Post_flag = Y */

            SELECT
                "par_Post_flag"
                INTO var_t_post_flag;

            IF "par_Transaction_type" = '201' OR /* Canc. of Admission */ "par_Transaction_type" = '200' OR /* Canc. of A/E */ SUBSTRING("par_Transaction_type", 1, 2) = '21' OR /* Canc. of inpatient discharge */ SUBSTRING("par_Transaction_type", 1, 2) = '35' OR /* Canc. of A/E discharge */ "par_Transaction_type" = '220' OR /* Canc. of Transfer */ "par_Transaction_type" = '230' OR /* Canc. of Trial Discharge */ "par_Transaction_type" = '240' OR /* Canc. of Return from Trial Discharge */ "par_Transaction_type" = '710' THEN /* Canc. of bed assignment */
                SELECT
                    'Y'
                    INTO var_t_post_flag;
            END IF;
           
            /*
            add to check the post datetime again since PB check it only just after open windows
            it can prevent writing 120, 121 without post_flag by Leo 20050204
            */
            IF "par_Transaction_type" = '120' AND "par_Post_flag" IS NULL THEN
                BEGIN
                    IF EXISTS (SELECT
                        *
                        FROM Transaction_log
                        WHERE Hospital_code = par_hosp AND Case_no = "par_Case_no" AND Transaction_type = '100' AND System_datetime = var_t_date AND Post_datetime IS NOT NULL) THEN
                        SELECT
                            'Y'
                            INTO var_t_post_flag;
                    END IF;
                END;
            END IF;

            IF "par_Transaction_type" = '121' AND "par_Post_flag" IS NULL THEN
                BEGIN
                    IF EXISTS (SELECT
                        *
                        FROM Transaction_log
                        WHERE Hospital_code = par_hosp AND Case_no = "par_Case_no" AND Transaction_type = '120' AND System_datetime = var_t_date AND Post_flag = 'Y') THEN
                        SELECT
                            'Y'
                            INTO var_t_post_flag;
                    END IF;
                END;
            END IF;

            WHILE 1 = 1 LOOP
                /* --- Modified by WL on 23 July 1999 for HPI--- */
                BEGIN
                    INSERT INTO Transaction_log (hospital_code, system_datetime, case_no, from_ward_code, from_treatment_location, from_class, from_bed, from_specialty_code, to_ward_code, to_treatment_location, to_class, to_bed, to_specialty_code, transaction_datetime, transaction_type, post_datetime, user_id, post_flag, cancel_flag)
                    VALUES (par_hosp, var_t_date, "par_Case_no", var_f_ward_code, var_f_treatment_location, var_f_class, var_f_bed, var_f_specialty_code, var_t_ward_code, var_t_treatment_location, var_t_class, var_t_bed, var_t_specialty_code, "par_Transaction_datetime", var_t_type, "par_Post_datetime", "par_User_ID", var_t_post_flag, var_cancel_flag);
                   raise notice 'hasp_insert_transaction_log(133)[INSERT]Transaction_log'; 
                   var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error := 1;
                           raise notice 't_log,errm=>%',sqlerrm;
                END;

                IF var_error != 0 THEN
                    BEGIN
                        EXIT error;
                    END;
                END IF;
                SELECT
                    "par_From_ward_code"
                    INTO var_t_ward_code;
                SELECT
                    "par_From_treatment_location"
                    INTO var_t_treatment_location;
                SELECT
                    "par_From_class"
                    INTO var_t_class;
                SELECT
                    "par_From_bed"
                    INTO var_t_bed;
                SELECT
                    "par_From_specialty_code"
                    INTO var_t_specialty_code;
                SELECT
                    "par_To_ward_code"
                    INTO var_f_ward_code;
                SELECT
                    "par_To_treatment_location"
                    INTO var_f_treatment_location;
                SELECT
                    "par_To_class"
                    INTO var_f_class;
                SELECT
                    "par_To_bed"
                    INTO var_f_bed;
                SELECT
                    "par_To_specialty_code"
                    INTO var_f_specialty_code;
                /* type '140' = transfer out and '141' = transfer in */
                IF "par_Transaction_type" = '140' AND var_t_type = '140' THEN
                    BEGIN
                        SELECT
                            '141'
                            INTO var_t_type;
                        CONTINUE;
                    END;
                ELSE
                    /* type '220' = cancel transfer out and '221' = cancel transfer in */
                    IF "par_Transaction_type" = '220' AND var_t_type = '220' THEN
                        BEGIN
                            SELECT
                                '221'
                                INTO var_t_type;
                            CONTINUE;
                        END;
                    ELSE
                        /* type '160' = trail discharge out and '161' = trial discharge in */
                        IF "par_Transaction_type" = '160' AND var_t_type = '160' THEN
                            BEGIN
                                SELECT
                                    '161'
                                    INTO var_t_type;
                                CONTINUE;
                            END;
                        ELSE
                            /* type '230' = canc. trial discharge out and '230' = canc. trial discharge in */
                            IF "par_Transaction_type" = '230' AND var_t_type = '230' THEN
                                BEGIN
                                    SELECT
                                        '231'
                                        INTO var_t_type;
                                    CONTINUE;
                                END;
                            ELSE
                                /*
                                type '170' = return from trial discharge out and
                                '171' = return from trial discharge in
                                */
                                IF "par_Transaction_type" = '170' AND var_t_type = '170' THEN
                                    BEGIN
                                        SELECT
                                            '171'
                                            INTO var_t_type;
                                        CONTINUE;
                                    END;
                                ELSE
                                    /*
                                    type '240' = canc. return from trial discharge out and
                                    '241' = canc. return from trial discharge in
                                    */
                                    IF "par_Transaction_type" = '240' AND var_t_type = '240' THEN
                                        BEGIN
                                            SELECT
                                                '241'
                                                INTO var_t_type;
                                            CONTINUE;
                                        END;
                                    ELSE
                                        EXIT;
                                    END IF;
                                END IF;
                            END IF;
                        END IF;
                    END IF;
                END IF;
            END LOOP;
            /* Delete corresponding Transaction for cancellation type */
            IF "par_Transaction_type" = '201' THEN /* Canc. of Admission */
                SELECT
                    '100'
                    INTO var_t_type;
            ELSE
                IF "par_Transaction_type" = '200' THEN /* Canc. of A/E */
                    SELECT
                        '300'
                        INTO var_t_type;
                ELSE
                    IF SUBSTRING("par_Transaction_type", 1, 2) = '21' THEN /* Canc. of inpatient discharge */
                        SELECT
                            CONCAT('13', SUBSTRING("par_Transaction_type", 3, 1))
                            INTO var_t_type;
                    ELSE
                        IF SUBSTRING("par_Transaction_type", 1, 2) = '35' THEN /* Canc. of A/E discharge */
                            SELECT
                                CONCAT('33', SUBSTRING("par_Transaction_type", 3, 1))
                                INTO var_t_type;
                        ELSE
                            IF "par_Transaction_type" = '220' THEN /* Canc. of Transfer */
                                SELECT
                                    '140'
                                    INTO var_t_type;
                            ELSE
                                IF "par_Transaction_type" = '230' THEN /* Canc. of Trial Discharge */
                                    SELECT
                                        '160'
                                        INTO var_t_type;
                                ELSE
                                    IF "par_Transaction_type" = '240' THEN /* Canc. of Return from Trial Discharge */
                                        SELECT
                                            '170'
                                            INTO var_t_type;
                                    ELSE
                                        IF "par_Transaction_type" = '710' THEN /* Canc. of bed assignment */
                                            SELECT
                                                '700'
                                                INTO var_t_type;
                                        ELSE
                                            EXIT end_delete_transaction_log;
                                        END IF;
                                    END IF;
                                END IF;
                            END IF;
                        END IF;
                    END IF;
                END IF;
            END IF;

            WHILE 1 = 1 LOOP
                /*
                delete Transaction_log
                where Transaction_datetime = @Transaction_datetime and
                      Transaction_type = @t_type and
                      Case_no = @Case_no and
                      System_datetime = ( select max(System_datetime)
                                            from Transaction_log
                                            where Transaction_datetime = @Transaction_datetime and
                                                  Transaction_type = @t_type and
                                                  Case_no = @Case_no )
                */
                /* --- Modified by WL on 23 July 1999 for HPI --- */
                BEGIN
                    UPDATE Transaction_log --+ index(XIE1Transaction_Log)
                    SET Cancel_flag = 'Y'
                        /* --from Transaction_log(index XIE1Transaction_log) */
                        WHERE Hospital_code = par_hosp 
                          AND Case_no = "par_Case_no" 
                          AND Transaction_datetime = "par_Transaction_datetime" 
                          AND Transaction_type = var_t_type
                          -- AND Transaction_type = "par_Transaction_type"
                          AND System_datetime = "par_Prev_system_datetime";  
                    raise notice 'hasp_insert_transaction_log(318)[UPDATE]Transaction_log'; 
                    var_error := 0;
                    EXCEPTION
                        WHEN OTHERS THEN
                            var_error := 1;
                           raise notice 't_log,errm=>%',sqlerrm;
                END;
                GET DIAGNOSTICS sql$rowcount = ROW_COUNT;
                var_rowcount := sql$rowcount;

                IF var_error != 0 THEN
                    EXIT error;
                END IF;

                IF var_rowcount = 0 THEN
                    BEGIN
                        /* -- test-- */
                        -- RAISE EXCEPTION '% ', 'Cannot Update Tx Log since NOT found' USING ERRCODE = 'P0001'; --200026
                        -- EXIT error;
                    END;
                ELSE
                    IF var_rowcount > 1 THEN
                        BEGIN
                            -- RAISE EXCEPTION '% ', 'More than one Tx Log found' USING ERRCODE = 'P0001'; --200026
                            -- EXIT error;
                        END;
                    END IF;
                END IF;

                IF "par_Transaction_type" = '220' AND /* Canc. of Transfer */ var_t_type = '140' THEN
                    BEGIN
                        SELECT
                            '141'
                            INTO var_t_type;
                        CONTINUE;
                    END;
                ELSE
                    IF "par_Transaction_type" = '230' AND /* Canc. of Trial Discharge */ var_t_type = '160' THEN
                        BEGIN
                            SELECT
                                '161'
                                INTO var_t_type;
                            CONTINUE;
                        END;
                    ELSE
                        IF "par_Transaction_type" = '240' AND /* Canc. of Return from Trial Discharge */ var_t_type = '170' THEN
                            BEGIN
                                SELECT
                                    '171'
                                    INTO var_t_type;
                                CONTINUE;
                            END;
                        ELSE
                            EXIT;
                        END IF;
                    END IF;
                END IF;
            END LOOP;
        END;
        pas_return_code := 0;
        RETURN;
    END;
    pas_return_code := 99;
    RETURN;
END;
$procedure$
;


;ALTER PROCEDURE "hasp_insert_transaction_log" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
