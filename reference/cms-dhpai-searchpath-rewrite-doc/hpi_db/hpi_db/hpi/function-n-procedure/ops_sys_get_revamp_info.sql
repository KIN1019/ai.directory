CREATE OR REPLACE PROCEDURE ops_sys_get_revamp_info(INOUT pas_return_code int, IN par_hospital VARCHAR, IN par_info_type VARCHAR)
AS 
$BODY$
/* --select convert(datetime, convert(VARCHAR(8), a.fx_exact_rollout_date, 112)) as rollout_date, b.parent_menu_id, b.menu_id, b.menu_description */
/* into ipas_revamp_info */
/* from opas_revamp_rollout_log a, java_menu_url b */
/* where 0 = 1 */

/* --while exists (select 0 from ipas_revamp_info where parent_menu_id not in (0, 10)) */

/* --begin */

/* --	-update #ipas_revamp_info_tmp */
/* set func_description = '[' + java_menu_url.menu_description + '] > ' + ipas_revamp_info.menu_description, */

/* --		   parent_menu_id = java_menu_url.parent_menu_id */

/* --	  from java_menu_url */

/* --	 where ipas_revamp_info.parent_menu_id not in (0, 10) */

/* --	   and java_menu_url.menu_id = ipas_revamp_info.parent_menu_id */

/* --end */
BEGIN
    IF par_info_type = 'PR' THEN /* PR = Past Rollout */
        select distinct rollout_dtm_exact, func_description
		from ipas_revamp_info
		where rollout_type='PR'
		order by rollout_dtm_exact desc, func_description;
    ELSE
        IF par_info_type = 'CR' THEN /* CR = Coming Rollout */
            select distinct rollout_dtm_exact, func_description
            	  from ipas_revamp_info
            		where rollout_type='CR'
            	order by rollout_dtm_exact, func_description;
        ELSE
            IF par_info_type = 'SK' THEN /* SK = Shortcut Key */
                select distinct rollout_dtm_exact, func_description
                	  from ipas_revamp_info
                		where rollout_type='SK'
                	order by rollout_dtm_exact desc, func_description;
            END IF;
        END IF;
    END IF;
END;
$BODY$
LANGUAGE plpgsql;