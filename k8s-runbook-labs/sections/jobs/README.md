# Jobs

Jobs create pods that run to completion. Used for batch processing, one-time tasks, and scheduled work via CronJobs.

## Job Types

- **Single Job**: Run once to completion
- **Parallel Jobs**: Run multiple pods in parallel
- **CronJob**: Scheduled jobs (like cron)

## Key Features

- Automatic retry on failure
- Completions and parallelism control
- Backoff limit for failed attempts
- Automatic cleanup with TTL

## Labs

- [Lab 01: Simple Job](labs/lab-01.md)
- [Lab 02: Parallel Job](labs/lab-02.md)
- [Lab 03: CronJob](labs/lab-03.md)
