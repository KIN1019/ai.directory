# Frequently Asked Questions (FAQ)

## Q: Does the Common Scheduler support `@Async` for long-running API calls?
**Answer**: The Common Scheduler supports multithreading and concurrent execution but does not support the use of `@Async`. To achieve concurrency, you can adjust the `thread_count` in the `application.yaml` file or set the `concurrent` flag in the scheduling job configuration.

Using the Java `@Async` annotation may result in unsupported behavior.

---
<details>
<summary>Example 1: `@Async` will be ignored if the scheduled job is not set to run asynchronously</summary>
<table>
  <tr>
    <th style="text-align: left;">Description</th>
  </tr>
  <tr>
    <td style="text-align: center;">
      <img src="https://hagithub.home/storage/user/2380/files/5cb5ca18-1374-42ab-a583-61e30caab5b4" alt="schedulerfwk_example1" />
      <img src="https://hagithub.home/storage/user/2380/files/1671ee6f-a6d8-4332-b312-df1005e1ccb1" alt="schedulerfwk_example1_log"/>
    </td>
  </tr>
</table>
</details>
---

<details>
  <summary>Example 2: Scheduled jobs will return immediately, and the scheduler job result will not be captured when the `@Async` call returns</summary>
  <table>
    <tr>
      <th style="text-align: left;">Description</th>
    </tr>
    <tr>
      <td style="text-align: center;">
        <img src="https://hagithub.home/storage/user/2380/files/4e6de967-596e-450d-817e-2f5b64a7db9e" alt="schedulerfwk_example2"/>
        <img src="https://hagithub.home/storage/user/2380/files/984c207d-0135-4dfe-b272-7261c38bcd64" alt="schedulerfwk_example2_log"/>
      </td>
    </tr>
  </table>
</details>

## Q: What is the cron expression format?
**Answer**: The cron expression format for a scheduling job consists of six or seven fields separated by spaces. The fields represent the following:

| Field         | Mandatory | Allowed Values        | Special Characters |
|---------------|-----------|-----------------------|--------------------|
| Seconds       | Yes       | `0-59`               | `, - * /`         |
| Minutes       | Yes       | `0-59`               | `, - * /`         |
| Hours         | Yes       | `0-23`               | `, - * /`         |
| Day of Month  | Yes       | `1-31`               | `, - * ? / L W C` |
| Month         | Yes       | `1-12` or `JAN-DEC`  | `, - * /`         |
| Day of Week   | Yes       | `1-7` or `SUN-SAT`   | `, - * ? / L C #` |
| Year (Optional) | No      | `1970-2099`          | `, - * /`         |

*Example Cron Expressions:*
1. `0 0 12 * * ?` - Executes at 12:00 PM every day.
2. `0 15 10 ? * MON-FRI` - Executes at 10:15 AM, Monday through Friday.
3. `0 0/5 14 * * ?` - Executes every 5 minutes starting at 2:00 PM and ending at 2:55 PM every day.

For more details, refer to the [Free Formatter Website](https://www.freeformatter.com/cron-expression-generator-quartz.html) to check your cron expression

## Q :  What is the end-to-end workflow of the scheduler library?
**Answer**: 
```mermaid
graph TD
    A[Spring Application Startup] --> B[Bean Initialization]
    B --> C[Process Beans with @CmsScheduler]
    C --> D[Scan all bean methods]
    D --> E{Method has @CmsScheduler?}
    E -->|Yes| F[Extract job parameters]
    E -->|No| D
    F --> G[Create JobDataMap]
    G --> H[Build JobDetail & Trigger]
    H --> I[Store in jobDetailTriggerMap]
    I --> D
    
    A --> J[Application Runner Executes]
    J --> K[Start Scheduler Thread]
    K --> L[Wait startup delay]
    L --> M[Reschedule Jobs]
    
    subgraph Reschedule Logic
        M --> N[Get existing JobKeys/TriggerKeys]
        N --> O[Compare with jobDetailTriggerMap]
        O --> P{Job exists in map?}
        P -->|Yes| Q[Update if needed]
        P -->|No| R[Remove old job]
        O --> S[Add new jobs from map]
    end
    
    S --> T[Start Quartz Scheduler]
    T --> U[Jobs execute per cron schedule]
```

## Q:  How do key components work together?
**Answer**:
```mermaid
graph LR
    Annotation[(@CmsScheduler)] -->|Triggers| Processor[BeanPostProcessor]
    Processor -->|Creates| JobConfig[Job Configuration]
    JobConfig -->|Stored in| Map[jobDetailTriggerMap]
    SchedulerThread -->|Uses| Map
    SchedulerThread -->|Manages| QuartzScheduler
    QuartzScheduler -->|Persists| JobStore[(Database)]
    
    classDef annotation fill:#F0B27A,stroke:#E67E22;
    classDef processor fill:#85C1E9,stroke:#2E86C1;
    classDef storage fill:#A9DFBF,stroke:#27AE60;
    
    class Annotation annotation
    class Processor processor
    class JobStore storage
```
---

## Q: How are jobs registered during startup?
**Answer**:
```mermaid
sequenceDiagram
    participant Spring
    participant BeanProcessor
    participant SchedulerThread
    
    Spring->>BeanProcessor: Initialize beans
    loop For each bean method
        BeanProcessor->>BeanProcessor: Check @CmsScheduler
        alt Has annotation
            BeanProcessor->>BeanProcessor: Build JobDetail/Trigger
            BeanProcessor->>jobDetailTriggerMap: Store configuration
        end
    end
    
    Spring->>SchedulerThread: Start after delay
    SchedulerThread->>Quartz: Reschedule jobs
    Quartz-->>SchedulerThread: Confirmation
    SchedulerThread->>Spring: Startup complete
```

**Registration Steps:**
1. Annotation scanning during bean initialization
2. Temporary storage of job configurations
3. Delayed scheduler thread startup
4. Final registration with Quartz

---

## Q: What happens during Application startup/restart?
**Answer**:
```mermaid
flowchart TB
    subgraph Reschedule Process
        direction TB
        A[Start] --> B[Fetch existing jobs]
        B --> C[Load current configs]
        C --> D{Compare}
        D -->|Orphaned jobs| E[Delete]
        D -->|New jobs| F[Add]
        D -->|Changed cron| G[Update]
        E --> H[Persist changes]
        F --> H
        G --> H
    end
    style Reschedule_Process fill:#FCF4D9,stroke:#F1C40F
```
---
## Q: What happens if have register some job and update the group name(default:DEFAULT) in application.yaml later?
```mermaid
graph LR
    OldVersion[Version 1: groupName=CMS_SCHEDULER] -->|Persists| DB[(Shared Database)]
    NewVersion[Version 2: group=CMS_COMMON_SCHEDULER] -->|Reads/Writes| DB
    DB -->|Contains| OldGroupJobs-OrphanedJobs[CMS_SCHEDULER_JOBS entries]
    DB -->|Contains| NewGroupJobs[CMS_COMMON_SCHEDULER_JOBS entries]
```
**Common Suggestion:**
1. Preserve Group Name (Recommended)
```properties
# Keep consistent across versions
cms.scheduler.group-name=MYAPP_JOBS
```