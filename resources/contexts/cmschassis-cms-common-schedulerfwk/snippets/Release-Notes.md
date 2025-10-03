# **0.0.4**

## New Features
  1. **Add Edit and Delete Button in the Maintenance Dashboard**  
     - **Edit**: Allows users to update the cron expression temporarily.  
     - **Delete**: Allows users to delete the scheduled job temporarily.  

  2. **Add Enable ReadOnly Maintenance Dashboard**  
     Introduced a read-only mode for the maintenance dashboard to restrict modifications.  

  3. **Add BPPM Notification Setting**  
     If enabled, specific BPPM log messages will be written and can be sent to CLAP. Users can create CLAP alerts later based on these logs.

## Improvements
  1. **Update Database Structure**  
     Added `{db_schema}` and `{db_prefix}` configurations in `application.yaml`, allowing users to configure the database schema.

  2. **Update the Maintenance Dashboard Login with Default Credentials**  
     If not specified in `application.yaml`, the default login credentials will be:  
     - **Username**: `admin`  
     - **Password**: Same as your scheduler name.

# **0.0.3**
## New Features
  - **Database Schema Properties**  
  Users can now integrate their product schemas with the common scheduler framework, enabling seamless and efficient scheduling processes.
## Improvements
  - **Enhanced Error Handling for Scheduling Failures**  
  The scheduler now only counts failures and triggers retries when a `CmsScheduleRetryException` is thrown. This ensures that unexpected exceptions do not interfere with scheduling failure alarms.  
  - **Updated Logging for CLAP Dashboard Integration**  
  The logging feature has been optimized to align with the new CLAP Dashboard ([CMS] CP14 Common Scheduler Dashboard v1.0.0).
## Bug Fixes

***
# **0.0.2**

## New Features
  - **Add Login Feature on Common Scheduler Maintenance Page**  
    Enhance security measures by ensuring that only authorized personnel can execute maintenance tasks, requiring users to enter their username and password for access.
  - **Enable Common Scheduler Monitoring Dashboard in CLAP**  
    Capture and present the status of scheduler jobs in CLAP format, facilitating real-time monitoring on the CLAP dashboard.

## Improvements
  - **Update Retry Setting for Scheduler Framework by Method Define**  
    Enhance the retry flexibility by allowing users to configure different retry counts for each scheduling job.

## Bug Fixes
***
# **0.0.1**
## New Features
## Improvements
## Bug Fixes