-- DROP PROCEDURE hpi.pass_pbpu_cpi_upd_adm_reg(in bpchar, in bpchar, in bpchar, in bpchar, in timestamp, in bpchar, in bpchar, in bpchar, inout int4);

CREATE OR REPLACE PROCEDURE hpi.pass_pbpu_cpi_upd_adm_reg(IN par_hospital_code character, IN par_case_no character, IN par_hkid character, IN par_patient_type_code character, IN par_tran_dtm timestamp without time zone, IN par_update_by character, IN par_type character, IN par_case_type character, INOUT par_return_code integer DEFAULT NULL::integer)
 LANGUAGE plpgsql
AS $procedure$ 

begin
	/* begin transaction */
	begin
		call cpi_update_adm_registration(
			par_return_code,
			par_hospital_code,
			par_case_no,
			par_hkid,
			null,
			null,
			null,
			par_patient_type_code,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			null,
			/* Wendy021116			'I', 
							'121', 
			*/
			par_case_type,
			par_type,
			'P',
			par_tran_dtm,
			par_update_by,
			 'PBRC',
			null,
			null,
			null,
			null);
		if par_return_code = 0 then
			/* commit transaction */
		else
			--rollback;

            raise exception '';
		end if;
	end;
end;
$procedure$
;

;ALTER PROCEDURE "pass_pbpu_cpi_upd_adm_reg" OWNER TO "HPI_SCHEMA_OWNER_ROLE";