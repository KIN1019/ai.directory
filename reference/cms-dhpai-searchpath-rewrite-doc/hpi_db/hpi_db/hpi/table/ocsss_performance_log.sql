-- ocsss_performance_log definition

-- Drop table

-- DROP TABLE ocsss_performance_log;

CREATE TABLE ocsss_performance_log (
	start_call_datetime timestamp(6) NOT NULL,
	end_call_datetime timestamp(6) NULL,
	check_ocsss varchar(2) NOT NULL,
	return_code int4 NOT NULL,
	ocsss_request_datetime varchar(34) NULL,
	ocsss_return_datetime varchar(34) NULL,
	ocsss_result varchar(2) NULL,
	ocsss_return_code varchar(6) NULL,
	hkid varchar(24) NOT NULL,
	hkic_symbol varchar(2) NULL,
	last_document_type varchar(10) NULL,
	pay_code varchar(6) NOT NULL,
	hospital varchar(6) NOT NULL,
	appt_seq int4 NOT NULL,
	update_by varchar(24) NOT NULL,
	update_datetime timestamp(6) NOT NULL,
	waiver_shorten_polled varchar(2) NULL,
	ref_id varchar(50) NULL
);
CREATE UNIQUE INDEX idx_ocsss_performance_log ON ocsss_performance_log USING btree (start_call_datetime, hkid, update_by);
CREATE INDEX idx_ocsss_performance_log1 ON ocsss_performance_log USING btree (hkid);
CREATE INDEX idx_ocsss_performance_log2 ON ocsss_performance_log USING btree (waiver_shorten_polled);




ALTER TABLE ocsss_performance_log OWNER TO "HPI_SCHEMA_OWNER_ROLE";
