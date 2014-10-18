require 'open-uri'
require 'turing-lib/heroku-tools'
require 'turing-lib/logging'

desc 'Called every 10 minutes - Heroku keep-alive and autoscale'
task :heroku_maintenance => :environment do
  log_exception() do
    startTime = Time.now
  
    log_console('STARTING heroku_maintenance')
  
    # heroku keep_alive
    log_exception() do
      log_console('STARTING heroku_maintenance - keep_alive')
  
      open("#{$config.url}/robots.txt")
  
      log_console('FINISHED heroku_maintenance - keep_alive')
    end
  
    # heroku dj_queue_size_check
    log_exception() do
      log_console('STARTING heroku_maintenance - dj_queue_size_check')
  
      dj_queue_size_alert = ''
  
      $config.dj_queues.each do |dj_queue|
        jobs_pending = Delayed::Job.where(:queue => dj_queue, :failed_at => nil).count
  
        dj_queue_size_alert << "#{dj_queue} jobs_pending=#{jobs_pending}\r\n\r\n" if jobs_pending >= $config.dj_queue_alert_size
      end
  
      log_email('QUEUE size ALERT!!!', dj_queue_size_alert) if !dj_queue_size_alert.blank?
  
      log_console('FINISHED heroku_maintenance - dj_queue_size_check')
    end
  
    # heroku scale dynos
    log_exception() do
      log_console('STARTING heroku_maintenance - scale dynos')
  
      $config.dj_queues_heroku_dynos.each do |queue, dyno|
        if Delayed::Job.where(:queue => queue, :failed_at => nil).count > 0
          num_dynos = HerokuTools::HerokuTools.count_dynos(dyno)

          if num_dynos == 0
            HerokuTools::HerokuTools.scale_dynos(dyno, 1)
          else
            log_console("SKIP scaling #{dyno} because num_dynos=#{num_dynos}")
          end
        else
          HerokuTools::HerokuTools.scale_dynos(dyno, 0)
        end
      end
  
      log_console('FINISHED heroku_maintenance - scale dynos')
    end
  
    log_console("EXITING heroku_maintenance #{Time.now - startTime}")
  end
end