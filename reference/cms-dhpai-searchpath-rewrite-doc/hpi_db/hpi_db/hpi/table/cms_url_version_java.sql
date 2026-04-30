-- cms_url_version_java definition

-- Drop table

-- DROP TABLE cms_url_version_java;

CREATE TABLE cms_url_version_java (
	hosp_code varchar(20) NOT NULL,
	"function" varchar(80) NOT NULL,
	"type" varchar(10) NOT NULL,
	"version" varchar(40) NOT NULL,
	protocol varchar(510) NOT NULL,
	host_name varchar(510) NULL,
	context_root varchar(510) NULL,
	login varchar(40) NULL,
	"password" varchar(40) NULL,
	version_info varchar(400) NULL,
	last_updated_by varchar(60) NULL,
	last_updated timestamp(6) NULL

	-- Remove "last_update_datetime" as there already exists "last_updated"
	--last_update_datetime timestamp(6) NULL
);
CREATE UNIQUE INDEX idx_cms_url_version_java ON cms_url_version_java USING btree (hosp_code, function, type);




ALTER TABLE cms_url_version_java OWNER TO "HPI_SCHEMA_OWNER_ROLE";
