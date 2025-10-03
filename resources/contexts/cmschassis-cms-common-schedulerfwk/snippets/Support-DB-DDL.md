## Tables Description
| Table Name                          | Usage Status | Purpose | Key Fields/Notes |
|-------------------------------------|--------------|---------|------------------|
| **`{db_prefix}_sfwk_blob_triggers`** | ❌ Rarely used | Stores trigger objects serialized as BLOBs (Binary Large Objects) for custom trigger types | `blob_data` - Serialized trigger object<br>Primary key: (sched_name, trigger_name, trigger_group) |
| **`{db_prefix}_sfwk_calendars`** | ❌ Rarely used | Stores calendar definitions used to exclude time periods from trigger firing | `calendar` - Serialized calendar object<br>`calendar_name` - Unique identifier |
| **`{db_prefix}_sfwk_cron_triggers`** | ✅ Very commonly used | Stores cron-style triggers that fire based on cron expressions | `cron_expression` - The cron pattern<br>`time_zone_id` - Timezone for schedule |
| **`{db_prefix}_sfwk_fired_triggers`** | ✅ Essential for monitoring | Tracks currently executing triggers for monitoring and recovery | `state` - Current execution state<br>`fired_time`/`sched_time` - Actual vs scheduled time<br>`requests_recovery` - Failure recovery flag |
| **`{db_prefix}_sfwk_job_details`** | ✅ Core table | Stores job definitions and metadata | `job_class_name` - Job implementation class<br>`job_data` - Serialized job data<br>Flags: `is_durable`, `requests_recovery` etc. |
| **`{db_prefix}_sfwk_locks`** | ✅ Used in clustered environments | Provides locking mechanism for cluster nodes | `lock_name` - Identifies lock type (e.g., "TRIGGER_ACCESS") |
| **`{db_prefix}_sfwk_paused_trigger_grps`** | ⚠️ Situationally used | Tracks paused trigger groups | `trigger_group` - Name of paused group |
| **`{db_prefix}_sfwk_scheduler_state`** | ✅ Used in clustered environments | Tracks state information for scheduler instances in a cluster | `instance_name` - Scheduler identifier<br>`last_checkin_time` - Last heartbeat<br>`checkin_interval` - Heartbeat frequency |
| **`{db_prefix}_sfwk_simple_triggers`** | ⚠️ Situationally used | Stores simple triggers that fire once or at fixed intervals | `repeat_count` - Number of repetitions<br>`repeat_interval` - Time between fires<br>`times_triggered` - Execution count |
| **`{db_prefix}_sfwk_simprop_triggers`** | ❌ Rarely used | Stores triggers with additional typed properties | Various property fields: `str_prop_#`, `int_prop_#`, `bool_prop_#`, etc. |
| **`{db_prefix}_sfwk_triggers`** | ✅ Core table | Main triggers table containing common trigger information | `trigger_state` - Current state<br>`trigger_type` - Trigger category<br>`next_fire_time`/`prev_fire_time` - Schedule timestamps<br>`misfire_instr` - Misfire handling |

### Usage Status Legend:
- ✅ **Commonly used**: Essential/core tables used in most implementations
- ⚠️ **Situationally used**: Only used for specific advanced scenarios
- ❌ **Rarely used**: Typically unused in standard configurations

### Important Notes:
1. Even "rarely used" tables are required for Common Schedulerfwk library complete schema
2. Usage frequency depends on your scheduling needs:
   - Cron triggers are most common
3. Please use the user with RW access for running the ddl and the application

## >= 0.0.4
Please replace the {db_schema} and {db_prefix} to your product schema name and prefix for the able
### PostgreSQL
```SQL
--Optional
DROP TABLE IF EXISTS {db_schema}.{db_prefix}_sfwk_blob_triggers CASCADE;
DROP TABLE IF EXISTS {db_schema}.{db_prefix}_sfwk_calendars CASCADE;
DROP TABLE IF EXISTS {db_schema}.{db_prefix}_sfwk_cron_triggers CASCADE;
DROP TABLE IF EXISTS {db_schema}.{db_prefix}_sfwk_fired_triggers CASCADE;
DROP TABLE IF EXISTS {db_schema}.{db_prefix}_sfwk_job_details CASCADE;
DROP TABLE IF EXISTS {db_schema}.{db_prefix}_sfwk_locks CASCADE;
DROP TABLE IF EXISTS {db_schema}.{db_prefix}_sfwk_paused_trigger_grps CASCADE;
DROP TABLE IF EXISTS {db_schema}.{db_prefix}_sfwk_scheduler_state CASCADE;
DROP TABLE IF EXISTS {db_schema}.{db_prefix}_sfwk_simple_triggers CASCADE;
DROP TABLE IF EXISTS {db_schema}.{db_prefix}_sfwk_simprop_triggers CASCADE;
DROP TABLE IF EXISTS {db_schema}.{db_prefix}_sfwk_triggers CASCADE;
```

```SQL
/************************************************************************************************/
/* Script Name: 010_create_table.sql                                                            */
/* Script Version: 1.0.0                                                                        */
/* Description: Setup schedulerfwk tables                                                       */
/************************************************************************************************/
/* Update History:                                                                              */
/*                                                                                              */
/* Date         CR #            Update details                               Updated By         */
/* ============================================================================================ */
/* 13-Mar-2025  TEAMCP14-60     init ddl for common scheduler               Brian Law           */
/************************************************************************************************/

\c {db_name};
--Create Database
CREATE TABLE {db_schema}.{db_prefix}_sfwk_blob_triggers (
    sched_name VARCHAR(120) NOT NULL,
    trigger_name VARCHAR(200) NOT NULL,
    trigger_group VARCHAR(200) NOT NULL,
    blob_data BYTEA,
    CONSTRAINT scheduler_scheduler_sfwk_blob_triggers_pkey PRIMARY KEY (sched_name, trigger_name, trigger_group)
);

CREATE TABLE {db_schema}.{db_prefix}_sfwk_calendars (
    sched_name VARCHAR(120) NOT NULL,
    calendar_name VARCHAR(200) NOT NULL,
    calendar BYTEA NOT NULL,
    CONSTRAINT scheduler_scheduler_sfwk_calendars_pkey PRIMARY KEY (sched_name, calendar_name)
);

CREATE TABLE {db_schema}.{db_prefix}_sfwk_cron_triggers (
    sched_name VARCHAR(120) NOT NULL,
    trigger_name VARCHAR(200) NOT NULL,
    trigger_group VARCHAR(200) NOT NULL,
    cron_expression VARCHAR(120) NOT NULL,
    time_zone_id VARCHAR(80),
    CONSTRAINT scheduler_scheduler_sfwk_cron_triggers_pkey PRIMARY KEY (sched_name, trigger_name, trigger_group)
);

CREATE TABLE {db_schema}.{db_prefix}_sfwk_fired_triggers (
    sched_name VARCHAR(120) NOT NULL,
    entry_id VARCHAR(95) NOT NULL,
    trigger_name VARCHAR(200) NOT NULL,
    trigger_group VARCHAR(200) NOT NULL,
    instance_name VARCHAR(200) NOT NULL,
    fired_time BIGINT NOT NULL,
    sched_time BIGINT NOT NULL,
    priority INTEGER NOT NULL,
    state VARCHAR(16) NOT NULL,
    job_name VARCHAR(200),
    job_group VARCHAR(200),
    is_nonconcurrent BOOLEAN,
    requests_recovery BOOLEAN,
    CONSTRAINT scheduler_scheduler_sfwk_fired_triggers_pkey PRIMARY KEY (sched_name, entry_id)
);

CREATE TABLE {db_schema}.{db_prefix}_sfwk_job_details (
    sched_name VARCHAR(120) NOT NULL,
    job_name VARCHAR(200) NOT NULL,
    job_group VARCHAR(200) NOT NULL,
    description VARCHAR(250),
    job_class_name VARCHAR(250) NOT NULL,
    is_durable BOOLEAN NOT NULL,
    is_nonconcurrent BOOLEAN NOT NULL,
    is_update_data BOOLEAN NOT NULL,
    requests_recovery BOOLEAN NOT NULL,
    job_data BYTEA,
    CONSTRAINT scheduler_scheduler_sfwk_job_details_pkey PRIMARY KEY (sched_name, job_name, job_group)
);

CREATE TABLE {db_schema}.{db_prefix}_sfwk_locks (
    sched_name VARCHAR(120) NOT NULL,
    lock_name VARCHAR(40) NOT NULL,
    CONSTRAINT scheduler_scheduler_sfwk_locks_pkey PRIMARY KEY (sched_name, lock_name)
);

CREATE TABLE {db_schema}.{db_prefix}_sfwk_paused_trigger_grps (
    sched_name VARCHAR(120) NOT NULL,
    trigger_group VARCHAR(200) NOT NULL,
    CONSTRAINT scheduler_scheduler_sfwk_paused_trigger_grps_pkey PRIMARY KEY (sched_name, trigger_group)
);

CREATE TABLE {db_schema}.{db_prefix}_sfwk_scheduler_state (
    sched_name VARCHAR(120) NOT NULL,
    instance_name VARCHAR(200) NOT NULL,
    last_checkin_time BIGINT NOT NULL,
    checkin_interval BIGINT NOT NULL,
    CONSTRAINT scheduler_scheduler_sfwk_scheduler_state_pkey PRIMARY KEY (sched_name, instance_name)
);

CREATE TABLE {db_schema}.{db_prefix}_sfwk_simple_triggers (
    sched_name VARCHAR(120) NOT NULL,
    trigger_name VARCHAR(200) NOT NULL,
    trigger_group VARCHAR(200) NOT NULL,
    repeat_count BIGINT NOT NULL,
    repeat_interval BIGINT NOT NULL,
    times_triggered BIGINT NOT NULL,
    CONSTRAINT scheduler_scheduler_sfwk_simple_triggers_pkey PRIMARY KEY (sched_name, trigger_name, trigger_group)
);

CREATE TABLE {db_schema}.{db_prefix}_sfwk_simprop_triggers (
    sched_name VARCHAR(120) NOT NULL,
    trigger_name VARCHAR(200) NOT NULL,
    trigger_group VARCHAR(200) NOT NULL,
    str_prop_1 VARCHAR(512),
    str_prop_2 VARCHAR(512),
    str_prop_3 VARCHAR(512),
    int_prop_1 INTEGER,
    int_prop_2 INTEGER,
    long_prop_1 BIGINT,
    long_prop_2 BIGINT,
    dec_prop_1 NUMERIC(13,4),
    dec_prop_2 NUMERIC(13,4),
    bool_prop_1 BOOLEAN,
    bool_prop_2 BOOLEAN,
    CONSTRAINT scheduler_scheduler_sfwk_simprop_triggers_pkey PRIMARY KEY (sched_name, trigger_name, trigger_group)
);

CREATE TABLE {db_schema}.{db_prefix}_sfwk_triggers (
    sched_name VARCHAR(120) NOT NULL,
    trigger_name VARCHAR(200) NOT NULL,
    trigger_group VARCHAR(200) NOT NULL,
    job_name VARCHAR(200) NOT NULL,
    job_group VARCHAR(200) NOT NULL,
    description VARCHAR(250),
    next_fire_time BIGINT,
    prev_fire_time BIGINT,
    priority INTEGER,
    trigger_state VARCHAR(16) NOT NULL,
    trigger_type VARCHAR(8) NOT NULL,
    start_time BIGINT NOT NULL,
    end_time BIGINT,
    calendar_name VARCHAR(200),
    misfire_instr SMALLINT,
    job_data BYTEA,
    CONSTRAINT scheduler_scheduler_sfwk_triggers_pkey PRIMARY KEY (sched_name, trigger_name, trigger_group)
);

--Create Index
CREATE INDEX idx_scheduler_scheduler_sfwk_ft_inst_job_req_rcvry
ON {db_schema}.{db_prefix}_sfwk_fired_triggers (
    sched_name,
    instance_name,
    requests_recovery
);

CREATE INDEX idx_scheduler_scheduler_sfwk_ft_j_g
ON {db_schema}.{db_prefix}_sfwk_fired_triggers (
    sched_name,
    job_name,
    job_group
);

CREATE INDEX idx_scheduler_scheduler_sfwk_ft_jg
ON {db_schema}.{db_prefix}_sfwk_fired_triggers (
    sched_name,
    job_group
);

CREATE INDEX idx_scheduler_scheduler_sfwk_ft_t_g
ON {db_schema}.{db_prefix}_sfwk_fired_triggers (
    sched_name,
    trigger_name,
    trigger_group
);

CREATE INDEX idx_scheduler_scheduler_sfwk_ft_tg
ON {db_schema}.{db_prefix}_sfwk_fired_triggers (
    sched_name,
    trigger_group
);

CREATE INDEX idx_scheduler_scheduler_sfwk_ft_trig_inst_name
ON {db_schema}.{db_prefix}_sfwk_fired_triggers (
    sched_name,
    instance_name
);

CREATE INDEX idx_scheduler_scheduler_sfwk_j_grp
ON {db_schema}.{db_prefix}_sfwk_job_details (
    sched_name,
    job_group
);

CREATE INDEX idx_scheduler_scheduler_sfwk_j_req_recovery
ON {db_schema}.{db_prefix}_sfwk_job_details (
    sched_name,
    requests_recovery
);

CREATE INDEX idx_scheduler_scheduler_sfwk_t_c
ON {db_schema}.{db_prefix}_sfwk_triggers (
    sched_name,
    calendar_name
);

CREATE INDEX idx_scheduler_scheduler_sfwk_t_g
ON {db_schema}.{db_prefix}_sfwk_triggers (
    sched_name,
    trigger_group
);

CREATE INDEX idx_scheduler_scheduler_sfwk_t_j
ON {db_schema}.{db_prefix}_sfwk_triggers (
    sched_name,
    job_name,
    job_group
);

CREATE INDEX idx_scheduler_scheduler_sfwk_t_jg
ON {db_schema}.{db_prefix}_sfwk_triggers (
    sched_name,
    job_group
);

CREATE INDEX idx_scheduler_scheduler_sfwk_t_n_g_state
ON {db_schema}.{db_prefix}_sfwk_triggers (
    sched_name,
    trigger_group,
    trigger_state
);

CREATE INDEX idx_scheduler_scheduler_sfwk_t_n_state
ON {db_schema}.{db_prefix}_sfwk_triggers (
    sched_name,
    trigger_name,
    trigger_group,
    trigger_state
);

CREATE INDEX idx_scheduler_scheduler_sfwk_t_next_fire_time
ON {db_schema}.{db_prefix}_sfwk_triggers (
    sched_name,
    next_fire_time
);

CREATE INDEX idx_scheduler_scheduler_sfwk_t_nft_misfire
ON {db_schema}.{db_prefix}_sfwk_triggers (
    sched_name,
    misfire_instr,
    next_fire_time
);

CREATE INDEX idx_scheduler_scheduler_sfwk_t_nft_st
ON {db_schema}.{db_prefix}_sfwk_triggers (
    sched_name,
    trigger_state,
    next_fire_time
);

CREATE INDEX idx_scheduler_scheduler_sfwk_t_nft_st_misfire
ON {db_schema}.{db_prefix}_sfwk_triggers (
    sched_name,
    misfire_instr,
    next_fire_time,
    trigger_state
);

CREATE INDEX idx_scheduler_scheduler_sfwk_t_nft_st_misfire_grp
ON {db_schema}.{db_prefix}_sfwk_triggers (
    sched_name,
    misfire_instr,
    next_fire_time,
    trigger_group,
    trigger_state
);

CREATE INDEX idx_scheduler_scheduler_sfwk_t_state
ON {db_schema}.{db_prefix}_sfwk_triggers (
    sched_name,
    trigger_state
);

--Add Foreign Key
ALTER TABLE {db_schema}.{db_prefix}_sfwk_blob_triggers
    ADD CONSTRAINT scheduler_scheduler_sfwk_blob_triggers_sched_name_trigger_name_trigger_group_fkey 
    FOREIGN KEY (sched_name, trigger_name, trigger_group)
    REFERENCES {db_schema}.{db_prefix}_sfwk_triggers(sched_name, trigger_name, trigger_group);

ALTER TABLE {db_schema}.{db_prefix}_sfwk_cron_triggers
    ADD CONSTRAINT scheduler_scheduler_sfwk_cron_triggers_sched_name_trigger_name_trigger_group_fkey FOREIGN KEY (sched_name, trigger_name, trigger_group)
    REFERENCES {db_schema}.{db_prefix}_sfwk_triggers(sched_name, trigger_name, trigger_group);

ALTER TABLE {db_schema}.{db_prefix}_sfwk_simple_triggers
    ADD CONSTRAINT scheduler_scheduler_sfwk_simple_triggers_sched_name_trigger_name_trigger_group_fkey FOREIGN KEY (sched_name, trigger_name, trigger_group)
    REFERENCES {db_schema}.{db_prefix}_sfwk_triggers(sched_name, trigger_name, trigger_group);

ALTER TABLE {db_schema}.{db_prefix}_sfwk_simprop_triggers
    ADD CONSTRAINT scheduler_schedulersfwk_simprop_triggers_sched_name_trigger_name_trigger_group_fkey FOREIGN KEY (sched_name, trigger_name, trigger_group)
    REFERENCES {db_schema}.{db_prefix}_sfwk_triggers(sched_name, trigger_name, trigger_group);

ALTER TABLE {db_schema}.{db_prefix}_sfwk_triggers
    ADD CONSTRAINT scheduler_schedulersfwk_triggers_sched_name_job_name_job_group_fkey FOREIGN KEY (sched_name, job_name, job_group)
    REFERENCES {db_schema}.{db_prefix}_sfwk_job_details(sched_name, job_name, job_group);
```

## >= 0.0.3
Please replace the {sample} to your product schema name
### PostgreSQL
```SQL
--Optional
DROP TABLE IF EXISTS {sample}.sfwk_blob_triggers CASCADE;
DROP TABLE IF EXISTS {sample}.sfwk_calendars CASCADE;
DROP TABLE IF EXISTS {sample}.sfwk_cron_triggers CASCADE;
DROP TABLE IF EXISTS {sample}.sfwk_fired_triggers CASCADE;
DROP TABLE IF EXISTS {sample}.sfwk_job_details CASCADE;
DROP TABLE IF EXISTS {sample}.sfwk_locks CASCADE;
DROP TABLE IF EXISTS {sample}.sfwk_paused_trigger_grps CASCADE;
DROP TABLE IF EXISTS {sample}.sfwk_scheduler_state CASCADE;
DROP TABLE IF EXISTS {sample}.sfwk_simple_triggers CASCADE;
DROP TABLE IF EXISTS {sample}.sfwk_simprop_triggers CASCADE;
DROP TABLE IF EXISTS {sample}.sfwk_triggers CASCADE;
```

```SQL
--Create Database
CREATE TABLE {sample}.sfwk_blob_triggers (
    sched_name VARCHAR(120) NOT NULL,
    trigger_name VARCHAR(200) NOT NULL,
    trigger_group VARCHAR(200) NOT NULL,
    blob_data BYTEA,
    CONSTRAINT sfwk_blob_triggers_pkey PRIMARY KEY (sched_name, trigger_name, trigger_group)
);

CREATE TABLE {sample}.sfwk_calendars (
    sched_name VARCHAR(120) NOT NULL,
    calendar_name VARCHAR(200) NOT NULL,
    calendar BYTEA NOT NULL,
    CONSTRAINT sfwk_calendars_pkey PRIMARY KEY (sched_name, calendar_name)
);

CREATE TABLE {sample}.sfwk_cron_triggers (
    sched_name VARCHAR(120) NOT NULL,
    trigger_name VARCHAR(200) NOT NULL,
    trigger_group VARCHAR(200) NOT NULL,
    cron_expression VARCHAR(120) NOT NULL,
    time_zone_id VARCHAR(80),
    CONSTRAINT sfwk_cron_triggers_pkey PRIMARY KEY (sched_name, trigger_name, trigger_group)
);

CREATE TABLE {sample}.sfwk_fired_triggers (
    sched_name VARCHAR(120) NOT NULL,
    entry_id VARCHAR(95) NOT NULL,
    trigger_name VARCHAR(200) NOT NULL,
    trigger_group VARCHAR(200) NOT NULL,
    instance_name VARCHAR(200) NOT NULL,
    fired_time BIGINT NOT NULL,
    sched_time BIGINT NOT NULL,
    priority INTEGER NOT NULL,
    state VARCHAR(16) NOT NULL,
    job_name VARCHAR(200),
    job_group VARCHAR(200),
    is_nonconcurrent BOOLEAN,
    requests_recovery BOOLEAN,
    CONSTRAINT sfwk_fired_triggers_pkey PRIMARY KEY (sched_name, entry_id)
);

CREATE TABLE {sample}.sfwk_job_details (
    sched_name VARCHAR(120) NOT NULL,
    job_name VARCHAR(200) NOT NULL,
    job_group VARCHAR(200) NOT NULL,
    description VARCHAR(250),
    job_class_name VARCHAR(250) NOT NULL,
    is_durable BOOLEAN NOT NULL,
    is_nonconcurrent BOOLEAN NOT NULL,
    is_update_data BOOLEAN NOT NULL,
    requests_recovery BOOLEAN NOT NULL,
    job_data BYTEA,
    CONSTRAINT sfwk_job_details_pkey PRIMARY KEY (sched_name, job_name, job_group)
);

CREATE TABLE {sample}.sfwk_locks (
    sched_name VARCHAR(120) NOT NULL,
    lock_name VARCHAR(40) NOT NULL,
    CONSTRAINT sfwk_locks_pkey PRIMARY KEY (sched_name, lock_name)
);

CREATE TABLE {sample}.sfwk_paused_trigger_grps (
    sched_name VARCHAR(120) NOT NULL,
    trigger_group VARCHAR(200) NOT NULL,
    CONSTRAINT sfwk_paused_trigger_grps_pkey PRIMARY KEY (sched_name, trigger_group)
);

CREATE TABLE {sample}.sfwk_scheduler_state (
    sched_name VARCHAR(120) NOT NULL,
    instance_name VARCHAR(200) NOT NULL,
    last_checkin_time BIGINT NOT NULL,
    checkin_interval BIGINT NOT NULL,
    CONSTRAINT sfwk_scheduler_state_pkey PRIMARY KEY (sched_name, instance_name)
);

CREATE TABLE {sample}.sfwk_simple_triggers (
    sched_name VARCHAR(120) NOT NULL,
    trigger_name VARCHAR(200) NOT NULL,
    trigger_group VARCHAR(200) NOT NULL,
    repeat_count BIGINT NOT NULL,
    repeat_interval BIGINT NOT NULL,
    times_triggered BIGINT NOT NULL,
    CONSTRAINT sfwk_simple_triggers_pkey PRIMARY KEY (sched_name, trigger_name, trigger_group)
);

CREATE TABLE {sample}.sfwk_simprop_triggers (
    sched_name VARCHAR(120) NOT NULL,
    trigger_name VARCHAR(200) NOT NULL,
    trigger_group VARCHAR(200) NOT NULL,
    str_prop_1 VARCHAR(512),
    str_prop_2 VARCHAR(512),
    str_prop_3 VARCHAR(512),
    int_prop_1 INTEGER,
    int_prop_2 INTEGER,
    long_prop_1 BIGINT,
    long_prop_2 BIGINT,
    dec_prop_1 NUMERIC(13,4),
    dec_prop_2 NUMERIC(13,4),
    bool_prop_1 BOOLEAN,
    bool_prop_2 BOOLEAN,
    CONSTRAINT sfwk_simprop_triggers_pkey PRIMARY KEY (sched_name, trigger_name, trigger_group)
);

CREATE TABLE {sample}.sfwk_triggers (
    sched_name VARCHAR(120) NOT NULL,
    trigger_name VARCHAR(200) NOT NULL,
    trigger_group VARCHAR(200) NOT NULL,
    job_name VARCHAR(200) NOT NULL,
    job_group VARCHAR(200) NOT NULL,
    description VARCHAR(250),
    next_fire_time BIGINT,
    prev_fire_time BIGINT,
    priority INTEGER,
    trigger_state VARCHAR(16) NOT NULL,
    trigger_type VARCHAR(8) NOT NULL,
    start_time BIGINT NOT NULL,
    end_time BIGINT,
    calendar_name VARCHAR(200),
    misfire_instr SMALLINT,
    job_data BYTEA,
    CONSTRAINT sfwk_triggers_pkey PRIMARY KEY (sched_name, trigger_name, trigger_group)
);

--Create Index
CREATE INDEX idx_sfwk_ft_inst_job_req_rcvry
ON {sample}.sfwk_fired_triggers (
    sched_name,
    instance_name,
    requests_recovery
);

CREATE INDEX idx_sfwk_ft_j_g
ON {sample}.sfwk_fired_triggers (
    sched_name,
    job_name,
    job_group
);

CREATE INDEX idx_sfwk_ft_jg
ON {sample}.sfwk_fired_triggers (
    sched_name,
    job_group
);

CREATE INDEX idx_sfwk_ft_t_g
ON {sample}.sfwk_fired_triggers (
    sched_name,
    trigger_name,
    trigger_group
);

CREATE INDEX idx_sfwk_ft_tg
ON {sample}.sfwk_fired_triggers (
    sched_name,
    trigger_group
);

CREATE INDEX idx_sfwk_ft_trig_inst_name
ON {sample}.sfwk_fired_triggers (
    sched_name,
    instance_name
);

CREATE INDEX idx_sfwk_j_grp
ON {sample}.sfwk_job_details (
    sched_name,
    job_group
);

CREATE INDEX idx_sfwk_j_req_recovery
ON {sample}.sfwk_job_details (
    sched_name,
    requests_recovery
);

CREATE INDEX idx_sfwk_t_c
ON {sample}.sfwk_triggers (
    sched_name,
    calendar_name
);

CREATE INDEX idx_sfwk_t_g
ON {sample}.sfwk_triggers (
    sched_name,
    trigger_group
);

CREATE INDEX idx_sfwk_t_j
ON {sample}.sfwk_triggers (
    sched_name,
    job_name,
    job_group
);

CREATE INDEX idx_sfwk_t_jg
ON {sample}.sfwk_triggers (
    sched_name,
    job_group
);

CREATE INDEX idx_sfwk_t_n_g_state
ON {sample}.sfwk_triggers (
    sched_name,
    trigger_group,
    trigger_state
);

CREATE INDEX idx_sfwk_t_n_state
ON {sample}.sfwk_triggers (
    sched_name,
    trigger_name,
    trigger_group,
    trigger_state
);

CREATE INDEX idx_sfwk_t_next_fire_time
ON {sample}.sfwk_triggers (
    sched_name,
    next_fire_time
);

CREATE INDEX idx_sfwk_t_nft_misfire
ON {sample}.sfwk_triggers (
    sched_name,
    misfire_instr,
    next_fire_time
);

CREATE INDEX idx_sfwk_t_nft_st
ON {sample}.sfwk_triggers (
    sched_name,
    trigger_state,
    next_fire_time
);

CREATE INDEX idx_sfwk_t_nft_st_misfire
ON {sample}.sfwk_triggers (
    sched_name,
    misfire_instr,
    next_fire_time,
    trigger_state
);

CREATE INDEX idx_sfwk_t_nft_st_misfire_grp
ON {sample}.sfwk_triggers (
    sched_name,
    misfire_instr,
    next_fire_time,
    trigger_group,
    trigger_state
);

CREATE INDEX idx_sfwk_t_state
ON {sample}.sfwk_triggers (
    sched_name,
    trigger_state
);

--Add Foreign Key
ALTER TABLE {sample}.sfwk_blob_triggers
    ADD CONSTRAINT sfwk_blob_triggers_sched_name_trigger_name_trigger_group_fkey 
    FOREIGN KEY (sched_name, trigger_name, trigger_group)
    REFERENCES {sample}.sfwk_triggers(sched_name, trigger_name, trigger_group);

ALTER TABLE {sample}.sfwk_cron_triggers
    ADD CONSTRAINT sfwk_cron_triggers_sched_name_trigger_name_trigger_group_fkey FOREIGN KEY (sched_name, trigger_name, trigger_group)
    REFERENCES {sample}.sfwk_triggers(sched_name, trigger_name, trigger_group);

ALTER TABLE {sample}.sfwk_simple_triggers
    ADD CONSTRAINT sfwk_simple_triggers_sched_name_trigger_name_trigger_group_fkey FOREIGN KEY (sched_name, trigger_name, trigger_group)
    REFERENCES {sample}.sfwk_triggers(sched_name, trigger_name, trigger_group);

ALTER TABLE {sample}.sfwk_simprop_triggers
    ADD CONSTRAINT sfwk_simprop_triggers_sched_name_trigger_name_trigger_group_fkey FOREIGN KEY (sched_name, trigger_name, trigger_group)
    REFERENCES {sample}.sfwk_triggers(sched_name, trigger_name, trigger_group);

ALTER TABLE {sample}.sfwk_triggers
    ADD CONSTRAINT sfwk_triggers_sched_name_job_name_job_group_fkey FOREIGN KEY (sched_name, job_name, job_group)
    REFERENCES {sample}.sfwk_job_details(sched_name, job_name, job_group);
```

## >= 0.0.1
### PostgreSQL
```SQL
--Optional
DROP TABLE IF EXISTS qrtz_blob_triggers CASCADE;
DROP TABLE IF EXISTS qrtz_calendars CASCADE;
DROP TABLE IF EXISTS qrtz_cron_triggers CASCADE;
DROP TABLE IF EXISTS qrtz_fired_triggers CASCADE;
DROP TABLE IF EXISTS qrtz_job_details CASCADE;
DROP TABLE IF EXISTS qrtz_locks CASCADE;
DROP TABLE IF EXISTS qrtz_paused_trigger_grps CASCADE;
DROP TABLE IF EXISTS qrtz_scheduler_state CASCADE;
DROP TABLE IF EXISTS qrtz_simple_triggers CASCADE;
DROP TABLE IF EXISTS qrtz_simprop_triggers CASCADE;
DROP TABLE IF EXISTS qrtz_triggers CASCADE;
```

```SQL
--Create Database
CREATE TABLE qrtz_blob_triggers (
    sched_name VARCHAR(120) NOT NULL,
    trigger_name VARCHAR(200) NOT NULL,
    trigger_group VARCHAR(200) NOT NULL,
    blob_data BYTEA,
    CONSTRAINT qrtz_blob_triggers_pkey PRIMARY KEY (sched_name, trigger_name, trigger_group)
);

CREATE TABLE qrtz_calendars (
    sched_name VARCHAR(120) NOT NULL,
    calendar_name VARCHAR(200) NOT NULL,
    calendar BYTEA NOT NULL,
    CONSTRAINT qrtz_calendars_pkey PRIMARY KEY (sched_name, calendar_name)
);

CREATE TABLE qrtz_cron_triggers (
    sched_name VARCHAR(120) NOT NULL,
    trigger_name VARCHAR(200) NOT NULL,
    trigger_group VARCHAR(200) NOT NULL,
    cron_expression VARCHAR(120) NOT NULL,
    time_zone_id VARCHAR(80),
    CONSTRAINT qrtz_cron_triggers_pkey PRIMARY KEY (sched_name, trigger_name, trigger_group)
);

CREATE TABLE qrtz_fired_triggers (
    sched_name VARCHAR(120) NOT NULL,
    entry_id VARCHAR(95) NOT NULL,
    trigger_name VARCHAR(200) NOT NULL,
    trigger_group VARCHAR(200) NOT NULL,
    instance_name VARCHAR(200) NOT NULL,
    fired_time BIGINT NOT NULL,
    sched_time BIGINT NOT NULL,
    priority INTEGER NOT NULL,
    state VARCHAR(16) NOT NULL,
    job_name VARCHAR(200),
    job_group VARCHAR(200),
    is_nonconcurrent BOOLEAN,
    requests_recovery BOOLEAN,
    CONSTRAINT qrtz_fired_triggers_pkey PRIMARY KEY (sched_name, entry_id)
);

CREATE TABLE qrtz_job_details (
    sched_name VARCHAR(120) NOT NULL,
    job_name VARCHAR(200) NOT NULL,
    job_group VARCHAR(200) NOT NULL,
    description VARCHAR(250),
    job_class_name VARCHAR(250) NOT NULL,
    is_durable BOOLEAN NOT NULL,
    is_nonconcurrent BOOLEAN NOT NULL,
    is_update_data BOOLEAN NOT NULL,
    requests_recovery BOOLEAN NOT NULL,
    job_data BYTEA,
    CONSTRAINT qrtz_job_details_pkey PRIMARY KEY (sched_name, job_name, job_group)
);

CREATE TABLE qrtz_locks (
    sched_name VARCHAR(120) NOT NULL,
    lock_name VARCHAR(40) NOT NULL,
    CONSTRAINT qrtz_locks_pkey PRIMARY KEY (sched_name, lock_name)
);

CREATE TABLE qrtz_paused_trigger_grps (
    sched_name VARCHAR(120) NOT NULL,
    trigger_group VARCHAR(200) NOT NULL,
    CONSTRAINT qrtz_paused_trigger_grps_pkey PRIMARY KEY (sched_name, trigger_group)
);

CREATE TABLE qrtz_scheduler_state (
    sched_name VARCHAR(120) NOT NULL,
    instance_name VARCHAR(200) NOT NULL,
    last_checkin_time BIGINT NOT NULL,
    checkin_interval BIGINT NOT NULL,
    CONSTRAINT qrtz_scheduler_state_pkey PRIMARY KEY (sched_name, instance_name)
);

CREATE TABLE qrtz_simple_triggers (
    sched_name VARCHAR(120) NOT NULL,
    trigger_name VARCHAR(200) NOT NULL,
    trigger_group VARCHAR(200) NOT NULL,
    repeat_count BIGINT NOT NULL,
    repeat_interval BIGINT NOT NULL,
    times_triggered BIGINT NOT NULL,
    CONSTRAINT qrtz_simple_triggers_pkey PRIMARY KEY (sched_name, trigger_name, trigger_group)
);

CREATE TABLE qrtz_simprop_triggers (
    sched_name VARCHAR(120) NOT NULL,
    trigger_name VARCHAR(200) NOT NULL,
    trigger_group VARCHAR(200) NOT NULL,
    str_prop_1 VARCHAR(512),
    str_prop_2 VARCHAR(512),
    str_prop_3 VARCHAR(512),
    int_prop_1 INTEGER,
    int_prop_2 INTEGER,
    long_prop_1 BIGINT,
    long_prop_2 BIGINT,
    dec_prop_1 NUMERIC(13,4),
    dec_prop_2 NUMERIC(13,4),
    bool_prop_1 BOOLEAN,
    bool_prop_2 BOOLEAN,
    CONSTRAINT qrtz_simprop_triggers_pkey PRIMARY KEY (sched_name, trigger_name, trigger_group)
);

CREATE TABLE qrtz_triggers (
    sched_name VARCHAR(120) NOT NULL,
    trigger_name VARCHAR(200) NOT NULL,
    trigger_group VARCHAR(200) NOT NULL,
    job_name VARCHAR(200) NOT NULL,
    job_group VARCHAR(200) NOT NULL,
    description VARCHAR(250),
    next_fire_time BIGINT,
    prev_fire_time BIGINT,
    priority INTEGER,
    trigger_state VARCHAR(16) NOT NULL,
    trigger_type VARCHAR(8) NOT NULL,
    start_time BIGINT NOT NULL,
    end_time BIGINT,
    calendar_name VARCHAR(200),
    misfire_instr SMALLINT,
    job_data BYTEA,
    CONSTRAINT qrtz_triggers_pkey PRIMARY KEY (sched_name, trigger_name, trigger_group)
);

--Create Index
CREATE INDEX idx_qrtz_ft_inst_job_req_rcvry
ON qrtz_fired_triggers (
    sched_name,
    instance_name,
    requests_recovery
);

CREATE INDEX idx_qrtz_ft_j_g
ON qrtz_fired_triggers (
    sched_name,
    job_name,
    job_group
);

CREATE INDEX idx_qrtz_ft_jg
ON qrtz_fired_triggers (
    sched_name,
    job_group
);

CREATE INDEX idx_qrtz_ft_t_g
ON qrtz_fired_triggers (
    sched_name,
    trigger_name,
    trigger_group
);

CREATE INDEX idx_qrtz_ft_tg
ON qrtz_fired_triggers (
    sched_name,
    trigger_group
);

CREATE INDEX idx_qrtz_ft_trig_inst_name
ON qrtz_fired_triggers (
    sched_name,
    instance_name
);

CREATE INDEX idx_qrtz_j_grp
ON qrtz_job_details (
    sched_name,
    job_group
);

CREATE INDEX idx_qrtz_j_req_recovery
ON qrtz_job_details (
    sched_name,
    requests_recovery
);

CREATE INDEX idx_qrtz_t_c
ON qrtz_triggers (
    sched_name,
    calendar_name
);

CREATE INDEX idx_qrtz_t_g
ON qrtz_triggers (
    sched_name,
    trigger_group
);

CREATE INDEX idx_qrtz_t_j
ON qrtz_triggers (
    sched_name,
    job_name,
    job_group
);

CREATE INDEX idx_qrtz_t_jg
ON qrtz_triggers (
    sched_name,
    job_group
);

CREATE INDEX idx_qrtz_t_n_g_state
ON qrtz_triggers (
    sched_name,
    trigger_group,
    trigger_state
);

CREATE INDEX idx_qrtz_t_n_state
ON qrtz_triggers (
    sched_name,
    trigger_name,
    trigger_group,
    trigger_state
);

CREATE INDEX idx_qrtz_t_next_fire_time
ON qrtz_triggers (
    sched_name,
    next_fire_time
);

CREATE INDEX idx_qrtz_t_nft_misfire
ON qrtz_triggers (
    sched_name,
    misfire_instr,
    next_fire_time
);

CREATE INDEX idx_qrtz_t_nft_st
ON qrtz_triggers (
    sched_name,
    trigger_state,
    next_fire_time
);

CREATE INDEX idx_qrtz_t_nft_st_misfire
ON qrtz_triggers (
    sched_name,
    misfire_instr,
    next_fire_time,
    trigger_state
);

CREATE INDEX idx_qrtz_t_nft_st_misfire_grp
ON qrtz_triggers (
    sched_name,
    misfire_instr,
    next_fire_time,
    trigger_group,
    trigger_state
);

CREATE INDEX idx_qrtz_t_state
ON qrtz_triggers (
    sched_name,
    trigger_state
);

--Add Foreign Key
ALTER TABLE qrtz_blob_triggers
    ADD CONSTRAINT qrtz_blob_triggers_sched_name_trigger_name_trigger_group_fkey 
    FOREIGN KEY (sched_name, trigger_name, trigger_group)
    REFERENCES qrtz_triggers(sched_name, trigger_name, trigger_group);

ALTER TABLE qrtz_cron_triggers
    ADD CONSTRAINT qrtz_cron_triggers_sched_name_trigger_name_trigger_group_fkey FOREIGN KEY (sched_name, trigger_name, trigger_group)
    REFERENCES qrtz_triggers(sched_name, trigger_name, trigger_group);

ALTER TABLE qrtz_simple_triggers
    ADD CONSTRAINT qrtz_simple_triggers_sched_name_trigger_name_trigger_group_fkey FOREIGN KEY (sched_name, trigger_name, trigger_group)
    REFERENCES qrtz_triggers(sched_name, trigger_name, trigger_group);

ALTER TABLE qrtz_simprop_triggers
    ADD CONSTRAINT qrtz_simprop_triggers_sched_name_trigger_name_trigger_group_fkey FOREIGN KEY (sched_name, trigger_name, trigger_group)
    REFERENCES qrtz_triggers(sched_name, trigger_name, trigger_group);

ALTER TABLE qrtz_triggers
    ADD CONSTRAINT qrtz_triggers_sched_name_job_name_job_group_fkey FOREIGN KEY (sched_name, job_name, job_group)
    REFERENCES qrtz_job_details(sched_name, job_name, job_group);
```