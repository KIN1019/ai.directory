-- DROP PROCEDURE hpi.web_hasp_update_mo_bb(inout int4, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in varchar, in int4, in int4, in varchar, in varchar, in varchar, in timestamp, in varchar);

CREATE OR REPLACE PROCEDURE hpi.web_hasp_update_mo_bb(INOUT pas_return_code integer, IN par_action character varying, IN par_mo_hosp character varying, IN par_mo_case character varying, IN par_nb_hosp character varying, IN par_nb_case character varying, IN par_mo_case_org character varying, IN par_nb_case_org character varying, IN par_birth_order integer, IN par_preg_number integer, IN par_birth_loc character varying, IN par_birth_place character varying, IN par_user_id character varying, IN par_system_dtm timestamp without time zone, IN par_baby_hkid character varying DEFAULT NULL::bpchar)
 LANGUAGE plpgsql
AS $procedure$
/* for update mo/nb case no .. */
/* --- for 'A' & checked with @nb_case's HKID  to ensure same patient.. */
DECLARE
    var_retcode INTEGER;
    var_error_msg VARCHAR(255);
    var_error INTEGER;
    var_rowcount INTEGER;
    var_raiserror_msg VARCHAR(255);
    var_mo_hkid VARCHAR(12);

BEGIN
    <<error>>
    BEGIN
        var_retcode := 0;
        var_error := 0;
        var_error_msg := NULL;
        var_raiserror_msg := NULL;

        IF par_action = 'A' THEN
            BEGIN
                /* --- Ensure ONLY one records for eache Baby HKID --- */
                IF EXISTS (SELECT
                    *
                    FROM mother_baby_case_view
                    WHERE baby_hkid = par_baby_hkid) THEN
                    BEGIN
                        /* --set @retcode = -21 */
                        var_retcode := 3000021;
                        /* --select @error_msg = 'The Mother Baby Relationship already exists for Patient %1!',@baby_hkid */
                        /* --select @error_msg = 'The Mother Baby Relationship already exists for the Patient !' */
                       
                       EXIT error;
                    END;
                END IF;
            END;
        END IF;
        /* ---exec @retcode = cpi_update_mo_bb @action, @mo_hosp,@mo_case, --- HPI */
--        CALL web_cpi_update_mo_bb(par_action, par_mo_hosp, par_mo_case, par_nb_hosp, par_nb_case, par_mo_case_org, par_nb_case_org, par_birth_order, par_preg_number, par_birth_loc, par_birth_place, par_user_id, par_system_dtm, par_baby_hkid, var_retcode, web_cpi_update_mo_bb$refcur_1, web_cpi_update_mo_bb$refcur_2, web_cpi_update_mo_bb$refcur_3, web_cpi_update_mo_bb$refcur_4, web_cpi_update_mo_bb$refcur_5);

        CALL web_cpi_update_mo_bb(var_retcode, par_action, par_mo_hosp, par_mo_case, par_nb_hosp, par_nb_case, par_mo_case_org, par_nb_case_org, par_birth_order, par_preg_number, par_birth_loc, par_birth_place, par_user_id, par_system_dtm, par_baby_hkid);

		raise notice 'web_hasp_update_mo_b[var_retcode]=%',var_retcode ;
        IF var_retcode <> 0 THEN
            EXIT error;
        END IF;
        pas_return_code := 0;
        RETURN;
    END;
    pas_return_code := var_retcode;
    RETURN;
END;
$procedure$
;


;ALTER PROCEDURE "web_hasp_update_mo_bb" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
