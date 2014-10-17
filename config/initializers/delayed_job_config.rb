Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 5
Delayed::Worker.max_attempts = 5
Delayed::Worker.max_run_time = 5.minutes
Delayed::Worker.default_queue_name = 'worker'
