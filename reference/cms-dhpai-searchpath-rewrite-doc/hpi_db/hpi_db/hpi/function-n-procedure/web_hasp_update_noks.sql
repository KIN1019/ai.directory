-- DROP PROCEDURE hpi.web_hasp_update_noks(inout int4, in varchar, in timestamp, in varchar, in varchar, in varchar, in int4, in _varchar, in int4, in _varchar, in int4, in _varchar, in int4, in _varchar, in int4, in _varchar, in int4, in _varchar, in int4, in _varchar, in int4, in _varchar, in int4, in _varchar);

CREATE OR REPLACE PROCEDURE hpi.web_hasp_update_noks(INOUT pas_return_code integer, IN par_hosp_code character varying, IN par_system_datetime timestamp without time zone, IN par_t_prk character varying, IN par_hkid character varying, IN par_user_id character varying, IN par_nok2_priority integer DEFAULT 2, IN par_nok2_arr character varying[] DEFAULT NULL::bpchar[], IN par_nok3_priority integer DEFAULT 3, IN par_nok3_arr character varying[] DEFAULT NULL::bpchar[], IN par_nok4_priority integer DEFAULT 4, IN par_nok4_arr character varying[] DEFAULT NULL::bpchar[], IN par_nok5_priority integer DEFAULT 5, IN par_nok5_arr character varying[] DEFAULT NULL::bpchar[], IN par_nok6_priority integer DEFAULT 6, IN par_nok6_arr character varying[] DEFAULT NULL::bpchar[], IN par_nok7_priority integer DEFAULT 7, IN par_nok7_arr character varying[] DEFAULT NULL::bpchar[], IN par_nok8_priority integer DEFAULT 8, IN par_nok8_arr character varying[] DEFAULT NULL::bpchar[], IN par_nok9_priority integer DEFAULT 9, IN par_nok9_arr character varying[] DEFAULT NULL::bpchar[], IN par_nok10_priority integer DEFAULT 10, IN par_nok10_arr character varying[] DEFAULT NULL::bpchar[])
 LANGUAGE plpgsql
AS $procedure$
declare
    var_retcode INTEGER;
    var_error_msg VARCHAR(255);
    var_priority INTEGER;
    nok_csr cursor for
        select
            priority
        from
            cpi_nok
        where
            patient_key = par_T_PRK
            and major_nok <> 'Y';

-- web_hasp_update_nok$refcur_1 refcursor;

begin
    <<error>>
    begin
        /* --delete all non-major contact persons before update patient */
	     raise notice '[web_hasp_update_noks] flag1111' ;

        if par_NOK2_arr is null or par_NOK2_arr[1] is null then
            begin
                open nok_csr;
                fetch nok_csr into var_priority;
                raise notice '[web_hasp_update_noks:26]var_priority=>%',var_priority;
                while (case
                    when found then 0
                    when not found then 2
                    else 1
                    end) = 0 loop
	                 raise notice '[web_hasp_update_noks:26]var_priority=>%',var_priority;

                     call web_hasp_update_nok(
        
                                             pas_return_code => var_retcode,
                                             par_hosp_code => par_hosp_code,
                                             par_System_datetime => par_System_datetime,
                                             par_T_PRK => par_T_PRK,
                                             par_HKID => par_HKID,
                                             par_User_ID => par_User_ID,
                                             par_NOK_priority => var_priority
                                             );
                                             -- ,p_refcur => web_hasp_update_nok$refcur_1);

                                                         --,p_refcur => web_hasp_update_nok$refcur_1);

                    if var_retcode != 0 then
                        exit error;
                    end if;

                    fetch nok_csr into var_priority;
                end loop;

                -- close web_hasp_update_nok$refcur_1;

                close nok_csr;

                pas_return_code := 0;
                raise notice '[web_hasp_update_noks:54] return_code=>0';
                return;
            end;
        end if;
        raise notice '[web_hasp_update_noks:57],%',par_NOK2_arr[1];
        call web_hasp_update_nok(
        
                                             pas_return_code => var_retcode,
                                             par_hosp_code => par_hosp_code,
                                             par_System_datetime => par_System_datetime,
                                             par_T_PRK => par_T_PRK,
                                             par_HKID => par_HKID,
                                             par_User_ID => par_User_ID,
                                             par_NOK_priority => par_NOK2_priority,
                                             par_NOK_name => par_NOK2_arr[1],
                                             par_NOK_HKID => par_NOK2_arr[2],
                                             par_NOK_relation_code => par_NOK2_arr[3],
                                             par_NOK_building => par_NOK2_arr[4],
                                             par_NOK_room => par_NOK2_arr[5],
                                             par_NOK_floor => par_NOK2_arr[6],
                                             par_NOK_block => par_NOK2_arr[7],
                                             par_NOK_district_code =>par_NOK2_arr[8],
                                             par_NOK_phone1 => par_NOK2_arr[9],
                                             par_NOK_phone2 => par_NOK2_arr[10],
                                             par_NOK_address_indicator => par_NOK2_arr[11],
                                             par_NOK_mobile_phone => par_NOK2_arr[12],
                                             par_NOK_sms_language => par_NOK2_arr[13]);
                                             -- ,p_refcur => web_hasp_update_nok$refcur_1);

        -- close web_hasp_update_nok$refcur_1;

        if var_retcode != 0 then
            exit error;
        end if;
			     raise notice '[web_hasp_update_noks] NOK2' ;

        call web_hasp_update_nok(
                                             pas_return_code => var_retcode,
                                             par_hosp_code => par_hosp_code,
                                             par_System_datetime => par_System_datetime,
                                             par_T_PRK => par_T_PRK,
                                             par_HKID => par_HKID,
                                             par_User_ID => par_User_ID,
                                             par_NOK_priority => par_NOK3_priority,
                                             par_NOK_name => par_NOK3_arr[1],
                                             par_NOK_HKID => par_NOK3_arr[2],
                                             par_NOK_relation_code => par_NOK3_arr[3],
                                             par_NOK_building => par_NOK3_arr[4],
                                             par_NOK_room => par_NOK3_arr[5],
                                             par_NOK_floor => par_NOK3_arr[6],
                                             par_NOK_block => par_NOK3_arr[7],
                                             par_NOK_district_code =>par_NOK3_arr[8],
                                             par_NOK_phone1 => par_NOK3_arr[9],
                                             par_NOK_phone2 => par_NOK3_arr[10],
                                             par_NOK_address_indicator => par_NOK3_arr[11],
                                             par_NOK_mobile_phone => par_NOK3_arr[12],
                                             par_NOK_sms_language => par_NOK3_arr[13]);
                                             -- ,p_refcur => web_hasp_update_nok$refcur_1);

        -- close web_hasp_update_nok$refcur_1;

        if var_retcode != 0 then
            exit error;
        end if;
               raise notice '[web_hasp_update_noks] NOK3' ;
        call web_hasp_update_nok(
                                             pas_return_code => var_retcode,par_hosp_code => par_hosp_code,
                                             par_System_datetime => par_System_datetime,
                                             par_T_PRK => par_T_PRK,
                                             par_HKID => par_HKID,
                                             par_User_ID => par_User_ID,
                                             par_NOK_priority => par_NOK4_priority,
                                             par_NOK_name => par_NOK4_arr[1],
                                             par_NOK_HKID => par_NOK4_arr[2],
                                             par_NOK_relation_code => par_NOK4_arr[3],
                                             par_NOK_building => par_NOK4_arr[4],
                                             par_NOK_room => par_NOK4_arr[5],
                                             par_NOK_floor => par_NOK4_arr[6],
                                             par_NOK_block => par_NOK4_arr[7],
                                             par_NOK_district_code =>par_NOK4_arr[8],
                                             par_NOK_phone1 => par_NOK4_arr[9],
                                             par_NOK_phone2 => par_NOK4_arr[10],
                                             par_NOK_address_indicator => par_NOK4_arr[11],
                                             par_NOK_mobile_phone => par_NOK4_arr[12],
                                             par_NOK_sms_language => par_NOK4_arr[13]);
                                             -- ,p_refcur => web_hasp_update_nok$refcur_1);

        -- close web_hasp_update_nok$refcur_1;

        if var_retcode != 0 then
            exit error;
        end if;
        raise notice '[web_hasp_update_noks] NOK4' ;

        call web_hasp_update_nok(
                                             pas_return_code => var_retcode,
                                             par_hosp_code => par_hosp_code,
                                             par_System_datetime => par_System_datetime,
                                             par_T_PRK => par_T_PRK,
                                             par_HKID => par_HKID,
                                             par_User_ID => par_User_ID,
                                             par_NOK_priority => par_NOK5_priority,
                                             par_NOK_name => par_NOK5_arr[1],
                                             par_NOK_HKID => par_NOK5_arr[2],
                                             par_NOK_relation_code => par_NOK5_arr[3],
                                             par_NOK_building => par_NOK5_arr[4],
                                             par_NOK_room => par_NOK5_arr[5],
                                             par_NOK_floor => par_NOK5_arr[6],
                                             par_NOK_block => par_NOK5_arr[7],
                                             par_NOK_district_code =>par_NOK5_arr[8],
                                             par_NOK_phone1 => par_NOK5_arr[9],
                                             par_NOK_phone2 => par_NOK5_arr[10],
                                             par_NOK_address_indicator => par_NOK5_arr[11],
                                             par_NOK_mobile_phone => par_NOK5_arr[12],
                                             par_NOK_sms_language => par_NOK5_arr[13]);
                                             -- ,p_refcur => web_hasp_update_nok$refcur_1);

        -- close web_hasp_update_nok$refcur_1;
        if var_retcode != 0 then
            exit error;
        end if;
        raise notice '[web_hasp_update_noks] NOK5' ;

        call web_hasp_update_nok(
                                             pas_return_code => var_retcode,
                                             par_hosp_code => par_hosp_code,
                                             par_System_datetime => par_System_datetime,
                                             par_T_PRK => par_T_PRK,
                                             par_HKID => par_HKID,
                                             par_User_ID => par_User_ID,
                                             par_NOK_priority => par_NOK6_priority,
                                             par_NOK_name => par_NOK6_arr[1],
                                             par_NOK_HKID => par_NOK6_arr[2],
                                             par_NOK_relation_code => par_NOK6_arr[3],
                                             par_NOK_building => par_NOK6_arr[4],
                                             par_NOK_room => par_NOK6_arr[5],
                                             par_NOK_floor => par_NOK6_arr[6],
                                             par_NOK_block => par_NOK6_arr[7],
                                             par_NOK_district_code =>par_NOK6_arr[8],
                                             par_NOK_phone1 => par_NOK6_arr[9],
                                             par_NOK_phone2 => par_NOK6_arr[10],
                                             par_NOK_address_indicator => par_NOK6_arr[11],
                                             par_NOK_mobile_phone => par_NOK6_arr[12],
                                             par_NOK_sms_language => par_NOK6_arr[13]);
                                             -- ,p_refcur => web_hasp_update_nok$refcur_1);

        -- close web_hasp_update_nok$refcur_1;

        if var_retcode != 0 then
            exit error;
        end if;
        raise notice '[web_hasp_update_noks] NOK6' ;

        call web_hasp_update_nok(
          pas_return_code => var_retcode,
          par_hosp_code => par_hosp_code,
                                             par_System_datetime => par_System_datetime,
                                             par_T_PRK => par_T_PRK,
                                             par_HKID => par_HKID,
                                             par_User_ID => par_User_ID,
                                             par_NOK_priority => par_NOK7_priority,
                                             par_NOK_name => par_NOK7_arr[1],
                                             par_NOK_HKID => par_NOK7_arr[2],
                                             par_NOK_relation_code => par_NOK7_arr[3],
                                             par_NOK_building => par_NOK7_arr[4],
                                             par_NOK_room => par_NOK7_arr[5],
                                             par_NOK_floor => par_NOK7_arr[6],
                                             par_NOK_block => par_NOK7_arr[7],
                                             par_NOK_district_code =>par_NOK7_arr[8],
                                             par_NOK_phone1 => par_NOK7_arr[9],
                                             par_NOK_phone2 => par_NOK7_arr[10],
                                             par_NOK_address_indicator => par_NOK7_arr[11],
                                             par_NOK_mobile_phone => par_NOK7_arr[12],
                                             par_NOK_sms_language => par_NOK7_arr[13]);
                                             -- ,p_refcur => web_hasp_update_nok$refcur_1);

        -- close web_hasp_update_nok$refcur_1;

        if var_retcode != 0 then
            exit error;
        end if;
        raise notice '[web_hasp_update_noks] NOK7' ;

        call web_hasp_update_nok(
         					 pas_return_code => var_retcode,
        						par_hosp_code => par_hosp_code,
                                             par_System_datetime => par_System_datetime,
                                             par_T_PRK => par_T_PRK,
                                             par_HKID => par_HKID,
                                             par_User_ID => par_User_ID,
                                             par_NOK_priority => par_NOK8_priority,
                                             par_NOK_name => par_NOK8_arr[1],
                                             par_NOK_HKID => par_NOK8_arr[2],
                                             par_NOK_relation_code => par_NOK8_arr[3],
                                             par_NOK_building => par_NOK8_arr[4],
                                             par_NOK_room => par_NOK8_arr[5],
                                             par_NOK_floor => par_NOK8_arr[6],
                                             par_NOK_block => par_NOK8_arr[7],
                                             par_NOK_district_code =>par_NOK8_arr[8],
                                             par_NOK_phone1 => par_NOK8_arr[9],
                                             par_NOK_phone2 => par_NOK8_arr[10],
                                             par_NOK_address_indicator => par_NOK8_arr[11],
                                             par_NOK_mobile_phone => par_NOK8_arr[12],
                                             par_NOK_sms_language => par_NOK8_arr[13]);
                                             -- ,p_refcur => web_hasp_update_nok$refcur_1);

        -- close web_hasp_update_nok$refcur_1;

        if var_retcode != 0 then
            exit error;
        end if;
        raise notice '[web_hasp_update_noks] NOK8' ;

        call web_hasp_update_nok(
          pas_return_code => var_retcode,	
        									par_hosp_code => par_hosp_code,
                                             par_System_datetime => par_System_datetime,
                                             par_T_PRK => par_T_PRK,
                                             par_HKID => par_HKID,
                                             par_User_ID => par_User_ID,
                                             par_NOK_priority => par_NOK9_priority,
                                             par_NOK_name => par_NOK9_arr[1],
                                             par_NOK_HKID => par_NOK9_arr[2],
                                             par_NOK_relation_code => par_NOK9_arr[3],
                                             par_NOK_building => par_NOK9_arr[4],
                                             par_NOK_room => par_NOK9_arr[5],
                                             par_NOK_floor => par_NOK9_arr[6],
                                             par_NOK_block => par_NOK9_arr[7],
                                             par_NOK_district_code =>par_NOK9_arr[8],
                                             par_NOK_phone1 => par_NOK9_arr[9],
                                             par_NOK_phone2 => par_NOK9_arr[10],
                                             par_NOK_address_indicator => par_NOK9_arr[11],
                                             par_NOK_mobile_phone => par_NOK9_arr[12],
                                             par_NOK_sms_language => par_NOK9_arr[13]);
                                             -- ,p_refcur => web_hasp_update_nok$refcur_1);

        -- close web_hasp_update_nok$refcur_1;

        if var_retcode != 0 then
            exit error;
        end if;
        raise notice '[web_hasp_update_noks] NOK9' ;

        call web_hasp_update_nok(
          pas_return_code => var_retcode,par_hosp_code => par_hosp_code,
                                             par_System_datetime => par_System_datetime,
                                             par_T_PRK => par_T_PRK,
                                             par_HKID => par_HKID,
                                             par_User_ID => par_User_ID,
                                             par_NOK_priority => par_NOK10_priority,
                                             par_NOK_name => par_NOK10_arr[1],
                                             par_NOK_HKID => par_NOK10_arr[2],
                                             par_NOK_relation_code => par_NOK10_arr[3],
                                             par_NOK_building => par_NOK10_arr[4],
                                             par_NOK_room => par_NOK10_arr[5],
                                             par_NOK_floor => par_NOK10_arr[6],
                                             par_NOK_block => par_NOK10_arr[7],
                                             par_NOK_district_code =>par_NOK10_arr[8],
                                             par_NOK_phone1 => par_NOK10_arr[9],
                                             par_NOK_phone2 => par_NOK10_arr[10],
                                             par_NOK_address_indicator => par_NOK10_arr[11],
                                             par_NOK_mobile_phone => par_NOK10_arr[12],
                                             par_NOK_sms_language => par_NOK10_arr[13]);
                                             -- ,p_refcur => web_hasp_update_nok$refcur_1);

        -- close web_hasp_update_nok$refcur_1;

        if var_retcode != 0 then
            exit error;
        end if;
        raise notice '[web_hasp_update_noks] NOK10' ;

        pas_return_code := 0;

        return;
    end;

    raise exception 'Fail to update contact person' using ERRCODE := '299999';

    pas_return_code := var_retcode;

    return;
end;
$procedure$
;

;ALTER PROCEDURE "web_hasp_update_noks" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
