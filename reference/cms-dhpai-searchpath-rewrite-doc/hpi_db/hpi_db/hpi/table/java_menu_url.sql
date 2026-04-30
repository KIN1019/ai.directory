-- java_menu_url definition

-- Drop table

-- DROP TABLE java_menu_url;

CREATE TABLE java_menu_url (
	hospital_code varchar(6) NOT NULL,
	func_id int4 NOT NULL,
	func_description varchar(255) NOT NULL,
	application_id int4 NULL,
	function_id int4 NULL,
	operation_id int4 NULL,
	url varchar(255) NOT NULL,
	url_parm varchar(255) NOT NULL,
	icon_path varchar(255) NULL,
	proxy_url varchar(255) NULL,
	create_by varchar(24) NOT NULL,
	create_datetime timestamp(6) NOT NULL,
	update_by varchar(24) NULL,
	update_datetime timestamp(6) NULL,
	show_on_menu varchar(2) NULL,
	proxy_url_by_hospital varchar(2) NULL
);
CREATE UNIQUE INDEX idx_java_menu_url ON java_menu_url USING btree (func_id, hospital_code);




ALTER TABLE java_menu_url OWNER TO "HPI_SCHEMA_OWNER_ROLE";
