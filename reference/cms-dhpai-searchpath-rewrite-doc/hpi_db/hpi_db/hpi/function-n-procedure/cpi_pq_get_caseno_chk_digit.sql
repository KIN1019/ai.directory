-- DROP PROCEDURE hpi.cpi_pq_get_caseno_chk_digit(inout int4, in varchar, in varchar, inout varchar);

CREATE OR REPLACE PROCEDURE hpi.cpi_pq_get_caseno_chk_digit(INOUT pas_return_code integer, IN par_caseno character varying, IN par_hospital_code character varying, INOUT par_check_digit character varying)
 LANGUAGE plpgsql
AS $procedure$
/*
Return values   Meaning
1               Format Error
*/
DECLARE
    var_error INTEGER;
    var_rowcount INTEGER;
    var_char_part CHAR(2);
    var_num_part CHAR(6);
    var_check_sum INTEGER;
    var_idx INTEGER;
    var_shift_factor INTEGER;
    var_ck_digit_str CHAR(36);
    var_aeno CHAR(08);
    var_hnno CHAR(08);
    var_opcode CHAR(04);
    var_opno CHAR(07);
BEGIN
    IF SUBSTRING(par_caseno, 1, 3) <> ' AE' AND SUBSTRING(par_caseno, 1, 3) <> ' HN' THEN
        SELECT
            CONCAT(RIGHT(CONCAT(REPEAT(' ', 04), RTRIM(SUBSTRING(par_caseno, 1, 4))), 4), SUBSTRING(par_caseno, 5, 8))
            INTO par_caseno;
    END IF;
    /* The first 2 digits does not used for check digit calculation */
    SELECT
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'
        INTO var_ck_digit_str;
    SELECT
        shift_factor
        INTO var_shift_factor
        FROM hospital
        WHERE hospital_code = par_hospital_code;
    /*
    For TMH, some of the old case no's shift factor is 0, but not 1
    the following routine reset the shift factor
    */
    IF par_hospital_code = 'TMH' THEN
        BEGIN
            IF SUBSTRING(par_caseno, 1, 3) = ' AE' AND SUBSTRING(par_caseno, 4, 2) < '93' AND SUBSTRING(par_caseno, 4, 2) > '80' THEN
                BEGIN
                    SELECT
                        SUBSTRING(par_caseno, 4, 8)
                        INTO var_aeno;
                    /*
                    if  @aeno < '92226791' or
                                    	    @aeno < '92900547' and @aeno !< '92900000'
                                    		select  @shift_factor = 0
                    */
		            if  var_aeno < '92226791' or var_aeno < '92900547' and var_aeno >= '92900000' then
					    SELECT 0 INTO var_shift_factor;
					end if;
                END;
            ELSE
                IF SUBSTRING(par_caseno, 1, 3) = ' HN' AND SUBSTRING(par_caseno, 4, 2) < '93' AND SUBSTRING(par_caseno, 4, 2) > '80' THEN
                    BEGIN
                        SELECT
                            SUBSTRING(par_caseno, 4, 8)
                            INTO var_hnno;
                        /*
                        if  @hnno < '92028023' or
                                            	    @hnno < '92900118' and @hnno !< '92900000' or
                                            	    @hnno <= '92800049' and @hnno !< '92800000' or
                                            	    @hnno < '92600026' and @hnno !< '92600000'
                                            		select  @shift_factor = 0
                        */
                        if  var_hnno < '92028023' or
                                            	    var_hnno < '92900118' and var_hnno >= '92900000' or
                                            	    var_hnno <= '92800049' and var_hnno >= '92800000' or
                                            	    var_hnno < '92600026' and var_hnno >= '92600000' then
						        SELECT 0 INTO var_shift_factor;
							end if;
                    END;
                ELSE
                    IF SUBSTRING(par_caseno, 5, 2) < '93' AND SUBSTRING(par_caseno, 5, 2) > '80' THEN
                        BEGIN
                            SELECT
                                SUBSTRING(par_caseno, 1, 4)
                                INTO var_opcode;
                            SELECT
                                SUBSTRING(par_caseno, 5, 7)
                                INTO var_opno;

                            IF var_opcode = ' ENT' AND var_opno < '9202168' OR var_opcode = ' GER' AND var_opno < '9203058' OR var_opcode = ' MED' AND var_opno < '9203180' OR var_opcode = ' PED' AND var_opno < '9203092' OR var_opcode = ' GYN' AND var_opno < '9203520' OR var_opcode = ' SUR' AND var_opno < '9204819' OR var_opcode = ' ORT' AND var_opno < '9204273' OR var_opcode = ' NEU' AND var_opno < '9200614' OR var_opcode = '  RT' AND var_opno < '9201503' THEN
                                SELECT
                                    0
                                    INTO var_shift_factor;
                            END IF;
                        END;
                    END IF;
                END IF;
            END IF;
        END;
    END IF;
    /*
    if substring(@caseno, 3, 1) = space(01)
       select @check_sum = 119 * 10
    else
    */
   	raise notice 'var_shift_factor=%',var_shift_factor;
    SELECT
        (ASCII(SUBSTRING(par_caseno, 3, 1)) - 55) * 10
        INTO var_check_sum;
	raise notice '1var_check_sum=%',var_check_sum;
    IF SUBSTRING(par_caseno, 4, 1) >= '0' AND SUBSTRING(par_caseno, 4, 1) <= '9' THEN
        SELECT
            var_check_sum + CAST (SUBSTRING(par_caseno, 4, 1) AS INTEGER) * 9
            INTO var_check_sum;
    ELSE
        SELECT
            var_check_sum + (ASCII(SUBSTRING(par_caseno, 4, 1)) - 55) * 9
            INTO var_check_sum;
    END IF;
    raise notice '2var_check_sum=%',var_check_sum;
    SELECT
        5
        INTO var_idx;

    WHILE var_idx <= 11 LOOP
        SELECT
            var_check_sum + CAST (SUBSTRING(par_caseno, var_idx, 1) AS INTEGER) * (13 - var_idx)
            INTO var_check_sum;
        SELECT
            var_idx + 1
            INTO var_idx;
    END LOOP;
    raise notice '3var_check_sum=%',var_check_sum;
    SELECT
        (((11 - var_check_sum % 11) % 11 + var_shift_factor) % 36) + 1
        INTO var_check_sum;
    raise notice '4var_check_sum=%',var_check_sum;
    SELECT
        SUBSTRING(var_ck_digit_str, var_check_sum, 1)
        INTO par_check_digit;
    pas_return_code := 0;
    RETURN;
END;
$procedure$
;


;ALTER PROCEDURE "cpi_pq_get_caseno_chk_digit" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
