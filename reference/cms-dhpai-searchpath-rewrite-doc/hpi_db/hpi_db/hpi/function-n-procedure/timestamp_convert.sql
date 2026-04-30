-- DROP FUNCTION hpi.timestamp_convert(timestamp);

CREATE OR REPLACE FUNCTION hpi.timestamp_convert(par_timestamp timestamp without time zone)
 RETURNS timestamp without time zone
 LANGUAGE plpgsql
AS $function$
declare var_ms char(1);
pas_return_code INTEGER;
begin
select substring(to_char(par_timestamp,'YYYY-MM-DD HH24:MI:SS.ms') ,23,1) into var_ms;
select to_char(par_timestamp,'YYYY-MM-DD HH24:MI:SS.ms')::timestamp without time zone into par_timestamp;
select case when var_ms  in ('2','5','9') then par_timestamp + INTERVAL '1 ms'
		when var_ms  in ('0','3','6') then par_timestamp
		when var_ms  in ('1','4','7') then par_timestamp - INTERVAL '1 ms'
		when var_ms  = '8' then par_timestamp - INTERVAL '2 ms'
	end into par_timestamp;
   return par_timestamp;
END;
$function$
;


;ALTER FUNCTION "timestamp_convert" OWNER TO "HPI_SCHEMA_OWNER_ROLE";
