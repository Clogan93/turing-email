class Exception
  def log_message
    return "#{self.class}: #{self.message}\r\n\r\n#{self.backtrace}"
  end
end

def log_email(subject, text = ' ', to_console = true, to = $config.logs_email, delayed_send = false)
  log_exception() do
    text = ' ' if text == '' || text.nil?

    log_exception() do
=begin
      r = RestClient
      r = r.delay if delayed_send

      #r.post "#{$config.mailgun_api_url}/messages",
             :from => $config.logs_email_full,
             :to => to,
             :subject => "Pluto (#{Rails.env}) - #{subject}",
             :text => text
=end
    end

    if to_console
      console_output = subject
      console_output << "\r\n\r\n#{text}" if text != ' '
      log_console(console_output)
    end
  end
end

def log_email_exception(ex, to_console = true)
  log_email(ex.message, ex.log_message, to_console)
end

def log_console(message, job = nil)
  return job.log_console_wrapper(message) if job

  Rails.logger.info(message)
rescue
  log_email('log_console ERROR!!', message, false)
end

def log_console_exception(ex)
  log_console(ex.log_message)
end

def log_exception(email = true)
  yield
rescue Exception => ex
  log_console_exception(ex)

  if email
    subject = "log_exception - #{ex.message}"
    body = ex.log_message
    log_email(subject, body)
  end
end
