-- hpi.octopus_provider source

CREATE OR REPLACE VIEW hpi.octopus_provider with(security_invoker = on)
AS SELECT sp_id,
    sp_english_name,
    sp_english_short_name,
    sp_chinese_name
   FROM hpi.cpi_octopus_provider;






ALTER TABLE octopus_provider OWNER TO "HPI_SCHEMA_OWNER_ROLE";
