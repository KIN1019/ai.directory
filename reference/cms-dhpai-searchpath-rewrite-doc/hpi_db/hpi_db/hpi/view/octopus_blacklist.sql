-- hpi.octopus_blacklist source

CREATE OR REPLACE VIEW hpi.octopus_blacklist with(security_invoker = on)
AS SELECT system_datetime,
    blacklist_data,
    blacklist_name,
    blacklist_summ,
    eod_data,
    eod_name,
    eod_summ,
    cchs_data,
    cchs_name,
    cchs_summ,
    firm_data,
    firm_name,
    firm_summ
   FROM hpi.cpi_octopus_blacklist;






ALTER TABLE octopus_blacklist OWNER TO "HPI_SCHEMA_OWNER_ROLE";
