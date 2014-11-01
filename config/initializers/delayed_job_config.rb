Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 5
Delayed::Worker.max_attempts = 5
Delayed::Worker.max_run_time = 12.hours
Delayed::Worker.default_queue_name = 'worker'

module WorkerExtensions
  protected

  def handle_failed_job(job, error)
    if !job.payload_object.respond_to?(:error)
      text = "FAILED (#{job.attempts} prior attempts) with #{error.class.name}: #{error.message}"
      text = "Job #{job.name} (id=#{job.id}) #{text}"
      log_email('JOB FAILURE!!!', text)
    else
      log_console("handle_failed_job SKIPPING email!!")
    end

    super(job, error)
  end
end
Delayed::MessageSending
module Delayed
  module DelayMail
    def delay(options = {}, heroku_scale: true)
      HerokuTools::HerokuTools.scale_dynos('worker', 1) if heroku_scale

      DelayProxy.new(PerformableMailer, self, options)
    end
  end

  module MessageSending
    def delay(options = {}, heroku_scale: true)
      HerokuTools::HerokuTools.scale_dynos('worker', 1) if heroku_scale

      DelayProxy.new(PerformableMethod, self, options)
    end
  end

  class Worker
    prepend WorkerExtensions
  end
end
