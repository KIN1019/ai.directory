-- hkpmi.hkpmi_uid_table definition

-- Drop table

-- DROP TABLE hkpmi.hkpmi_uid_table;

CREATE TABLE hkpmi.hkpmi_uid_table (
	uid_hkid varchar(24) NOT NULL,
	link_hkid varchar(24) NOT NULL,
	link_status varchar(4) NOT NULL,
	create_dtm timestamp(6) NOT NULL,
	create_hospital varchar(6) NOT NULL,
	create_user varchar(24) NOT NULL,
	create_system varchar(10) NOT NULL,
	update_dtm timestamp(6) NOT NULL,
	update_hospital varchar(6) NOT NULL,
	update_user varchar(24) NOT NULL,
	update_system varchar(10) NOT NULL,
	CONSTRAINT hkpmi_uid_table_xpk PRIMARY KEY (uid_hkid)
);
CREATE INDEX hkpmi_uid_table_idx ON hkpmi.hkpmi_uid_table USING btree (link_hkid);
CREATE INDEX hkpmi_uid_table_idx2 ON hkpmi.hkpmi_uid_table USING btree (create_hospital, create_dtm);
CREATE INDEX hkpmi_uid_table_idx3 ON hkpmi.hkpmi_uid_table USING btree (update_hospital, update_dtm);
CREATE INDEX hkpmi_uid_table_idx4 ON hkpmi.hkpmi_uid_table USING btree (update_dtm);



ALTER TABLE hkpmi.hkpmi_uid_table OWNER TO "HKPMI_SCHEMA_OWNER_ROLE";
