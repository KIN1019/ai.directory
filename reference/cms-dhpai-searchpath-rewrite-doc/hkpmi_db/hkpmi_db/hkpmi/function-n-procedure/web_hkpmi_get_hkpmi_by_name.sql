CREATE OR REPLACE PROCEDURE web_hkpmi_get_hkpmi_by_name( INOUT pas_return_code int,IN par_name VARCHAR, IN par_sex VARCHAR, IN par_from_dob TIMESTAMP WITHOUT TIME ZONE, IN par_to_dob TIMESTAMP WITHOUT TIME ZONE, IN par_last_name VARCHAR, IN par_last_hkid VARCHAR, IN par_authority_code INTEGER, IN par_hosp_code VARCHAR, INOUT p_refcur refcursor)
 LANGUAGE plpgsql
AS $procedure$
/* --paging modify */
/*
@name = name input from screen
@sex  = M, F, U / MU / FU / U
@from_dob, @to_dob  = if user has input age, place into from_dob, to_dob
                      else place null
*/
DECLARE
    var_temp_int INTEGER;
    var_err INTEGER;
    var_t_dob TIMESTAMP WITHOUT TIME ZONE;
    var_t_mrn VARCHAR(8);
    var_t_hkid VARCHAR(12);
    var_t_name VARCHAR(48);
    var_t_tel VARCHAR(10);
    var_t_sex VARCHAR(01);
    var_i INTEGER;
    var_t_cccode1 VARCHAR(5);
    var_t_cccode2 VARCHAR(5);
    var_t_cccode3 VARCHAR(5);
    var_t_cccode4 VARCHAR(5);
    var_t_cccode5 VARCHAR(5);
    var_t_cccode6 VARCHAR(5);
    var_cccode1 VARCHAR(5);
    var_cccode2 VARCHAR(5);
    var_cccode3 VARCHAR(5);
    var_cccode4 VARCHAR(5);
    var_cccode5 VARCHAR(5);
    var_cccode6 VARCHAR(5);
    var_hkid VARCHAR(12);
    var_chi_name VARCHAR(12);
    var_schi_name VARCHAR(12);
    var_is_schi_name VARCHAR(1);
    var_tmp_phonetic VARCHAR(48);
    pmi_csr refcursor;
    
BEGIN
    DROP TABLE IF EXISTS t$temp_patient_list;
    CREATE TEMPORARY TABLE t$temp_patient_list
    (row_no BIGINT GENERATED ALWAYS AS IDENTITY,
        /* ---- To fix, SRV 16  #311  The optimizer could not find a unique index which it could use to scan table '#temp_patient_list' for cursor 'csr'. */
        hkid VARCHAR(12) NULL,
        name VARCHAR(48) NULL,
        sex VARCHAR(1) NULL,
        dob TIMESTAMP WITHOUT TIME ZONE NULL,
        mrn VARCHAR(8) NULL,
        phone1 VARCHAR(10) NULL,
        cccode1 VARCHAR(05) NULL,
        cccode2 VARCHAR(05) NULL,
        cccode3 VARCHAR(05) NULL,
        cccode4 VARCHAR(05) NULL,
        cccode5 VARCHAR(05) NULL,
        cccode6 VARCHAR(05) NULL,
        chi_name VARCHAR(12) NULL,
        schi_name VARCHAR(12) NULL);
    CREATE UNIQUE INDEX t$temp_patient_list_idx ON t$temp_patient_list
        (row_no);
    SELECT
        CONCAT(RTRIM(par_name), '%'), CONCAT('[', RTRIM(par_sex), ']')
        INTO par_name, par_sex;
    CALL hkpmi_get_int_by_bit(pas_return_code,'NNNNNNNNNNYYYYYYYYNNNNNNNNNNNNN', var_temp_int);
    SELECT
        par_authority_code & var_temp_int
        INTO par_authority_code;
    /* --- set rowcount  200 (deprecated) */

    IF par_from_dob is NULL THEN
        BEGIN
            /* --insert #temp_patient_list ---SHould not use select into which depend on DB option... */
            open pmi_csr FOR
            SELECT
                p.hkid, p.patient_name, p.sex, p.dob, h.mrn, p.phone1, p.cccode1, p.cccode2, p.cccode3, p.cccode4, p.cccode5, p.cccode6
                FROM patient AS p
                LEFT OUTER JOIN patient_hospital_data AS h
                    ON (p.patient_key = h.patient_key AND h.hospital_code = par_hosp_code)
                WHERE
                /* --paging modify */
                p.patient_name LIKE par_name AND p.patient_name >= par_last_name AND p.sex LIKE par_sex AND (p.access_code & par_authority_code) > 0;
        END;
    ELSE
        BEGIN
            BEGIN
                open pmi_csr FOR
                SELECT
                    p.hkid, p.patient_name, p.sex, p.dob, h.mrn, p.phone1, p.cccode1, p.cccode2, p.cccode3, p.cccode4, p.cccode5, p.cccode6
                    FROM patient AS p
                    LEFT OUTER JOIN patient_hospital_data AS h
                        ON (p.patient_key = h.patient_key AND h.hospital_code = par_hosp_code)
                    WHERE
                    /* --paging modify */
                    p.patient_name LIKE par_name AND p.patient_name >= par_last_name AND p.sex LIKE par_sex AND p.dob >= par_from_dob AND p.dob <= par_to_dob AND (p.access_code & par_authority_code) > 0;
            END;
        END;
    END IF;
    --OPEN pmi_csr;
    /* --paging modify */
    IF par_last_hkid IS NOT NULL THEN
        BEGIN
            WHILE 1 = 1 LOOP
                FETCH pmi_csr INTO var_t_hkid, var_t_name, var_t_sex, var_t_dob, var_t_mrn, var_t_tel, var_t_cccode1, var_t_cccode2, var_t_cccode3, var_t_cccode4, var_t_cccode5, var_t_cccode6;

                IF (CASE
                    WHEN FOUND THEN 0
                    WHEN NOT FOUND THEN 2
                    ELSE 1
                END) != 0 OR var_t_hkid = par_last_hkid THEN
                    EXIT;
                END IF;
            END LOOP;
        END;
    END IF;
    SELECT
        0
        INTO var_i;
    /* --while @i < 200		---- set rowcount  200 */

    WHILE var_i < 11 LOOP /* --paging modify */
        FETCH pmi_csr INTO var_t_hkid, var_t_name, var_t_sex, var_t_dob, var_t_mrn, var_t_tel, var_t_cccode1, var_t_cccode2, var_t_cccode3, var_t_cccode4, var_t_cccode5, var_t_cccode6;

        IF (CASE
            WHEN FOUND THEN 0
            WHEN NOT FOUND THEN 2
            ELSE 1
        END) != 0 THEN
            EXIT;
        END IF;
        INSERT INTO t$temp_patient_list (hkid,name,sex,dob, mrn,phone1,cccode1,cccode2,cccode3,cccode4,cccode5 ,cccode6,chi_name,schi_name)
        VALUES (var_t_hkid, var_t_name, var_t_sex, var_t_dob, var_t_mrn, var_t_tel, var_t_cccode1, var_t_cccode2, var_t_cccode3, var_t_cccode4, var_t_cccode5, var_t_cccode6, NULL, NULL);
        SELECT
            var_i + 1
            INTO var_i;
    END LOOP;
    CLOSE pmi_csr;
    /* ---------chi_name/schi_name ------- */
    /*
    Web use unicode
    	declare csr cursor for
    	 select hkid, cccode1,cccode2,cccode3,cccode4,cccode5,cccode6
    	   from #temp_patient_list
    	    for update
    
    	select @hkid = null,@cccode1 = null,@cccode2 = null,@cccode3 = null,@cccode4 = null,@cccode5 = null,@cccode6 = null
    
    	open csr
    	fetch csr into @hkid,@cccode1,@cccode2,@cccode3,@cccode4,@cccode5,@cccode6
    	while @@sqlstatus=0
    	begin
    	   /-* Get chinese name from ccc_big5 table *-/
       	exec  cpi_get_phonetic_chin_name
          	@cccode1, @cccode2, @cccode3, @cccode4, @cccode5, @cccode6,
          	@tmp_phonetic out, @chi_name out
    
    		select @err = @@error
    		if @err<>0
    		begin
    			drop table #temp_patient_list
    			RAISERROR 99999 'Unable to get phonetic Chinese name'
    			RETURN
    		end
    
    		select @schi_name = null
    	   if IsNull(@chi_name, '') <> ''
    	   begin
    	      exec hkpmi_check_schi_name
    	         @ccc1 = @cccode1, @ccc2 = @cccode2, @ccc3 = @cccode3,
    	         @ccc4 = @cccode4, @ccc5 = @cccode5, @ccc6 = @cccode6,
    	         @is_schi_name = @is_schi_name output
    	      if @is_schi_name = 'Y'
    	      begin
    	      	select @schi_name = @chi_name
    	      	select @chi_name = null
    	      end
    	   end
    
    		update #temp_patient_list
    		   set chi_name = @chi_name,
    		       schi_name = @schi_name
    		 	where current of csr
    		 	---where hkid = @hkid
    
    		select @hkid = null,@cccode1 = null,@cccode2 = null,@cccode3 = null,@cccode4 = null,@cccode5 = null,@cccode6 = null
    		fetch csr into @hkid,@cccode1,@cccode2,@cccode3,@cccode4,@cccode5,@cccode6
    	end
    
    	close csr
    
    	select hkid,name,sex,dob,mrn,phone1,chi_name,schi_name
    	from #temp_patient_list
    */
    /*
    [9996 - Severity CRITICAL - Transformer error occurred in fromClause. Please submit report to developers.]
    select hkid,name,sex,dob,mrn,phone1,
    	c1.unicode_int unicode_int1, c2.unicode_int unicode_int2, c3.unicode_int unicode_int3,
    	c4.unicode_int unicode_int4, c5.unicode_int unicode_int5, c6.unicode_int unicode_int6
    	from #temp_patient_list p,ccc_big5 c1, ccc_big5 c2, ccc_big5 c3, ccc_big5 c4, ccc_big5 c5, ccc_big5 c6
    	where c1.ccc_head =* substring(p.cccode1, 1, 4) and c1.ccc_tail =* substring(p.cccode1, 5, 1)
    	and c2.ccc_head =* substring(p.cccode2, 1, 4) and c2.ccc_tail =* substring(p.cccode2, 5, 1)
    	and c3.ccc_head =* substring(p.cccode3, 1, 4) and c3.ccc_tail =* substring(p.cccode3, 5, 1)
    	and c4.ccc_head =* substring(p.cccode4, 1, 4) and c4.ccc_tail =* substring(p.cccode4, 5, 1)
    	and c5.ccc_head =* substring(p.cccode5, 1, 4) and c5.ccc_tail =* substring(p.cccode5, 5, 1)
    	and c6.ccc_head =* substring(p.cccode6, 1, 4) and c6.ccc_tail =* substring(p.cccode6, 5, 1)
    */
    open p_refcur for select hkid,name,sex,dob,mrn,phone1,
    	c1.unicode_int unicode_int1, c2.unicode_int unicode_int2, c3.unicode_int unicode_int3,
    	c4.unicode_int unicode_int4, c5.unicode_int unicode_int5, c6.unicode_int unicode_int6
    from t$temp_patient_list p
    RIGHT JOIN ccc_unicode c1 ON c1.ccc_head = substring(p.cccode1, 1, 4) and c1.ccc_tail = substring(p.cccode1, 5, 1)
    RIGHT JOIN ccc_unicode c2 ON c2.ccc_head = substring(p.cccode2, 1, 4) and c2.ccc_tail = substring(p.cccode2, 5, 1)
    RIGHT JOIN ccc_unicode c3 ON c3.ccc_head = substring(p.cccode3, 1, 4) and c3.ccc_tail = substring(p.cccode3, 5, 1)
    RIGHT JOIN ccc_unicode c4 ON c4.ccc_head = substring(p.cccode4, 1, 4) and c4.ccc_tail = substring(p.cccode4, 5, 1)
    RIGHT JOIN ccc_unicode c5 ON c5.ccc_head = substring(p.cccode5, 1, 4) and c5.ccc_tail = substring(p.cccode5, 5, 1)
    RIGHT JOIN ccc_unicode c6 ON c6.ccc_head = substring(p.cccode6, 1, 4) and c6.ccc_tail = substring(p.cccode6, 5, 1);

    -- DROP TABLE t$temp_patient_list;
    /* ----set rowcount 0 */
    pas_return_code := 0;
    RETURN;
    /*
    
    DROP TABLE IF EXISTS t$temp_patient_list;
    */
    /*
    
    Temporary table must be removed before end of the function.
    */
END;
$procedure$
;

ALTER PROCEDURE "web_hkpmi_get_hkpmi_by_name" OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
