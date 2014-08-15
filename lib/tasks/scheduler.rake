require 'open-uri'

desc "This task is called by the Heroku scheduler add-on"

task :keep_dyno_alive => :environment do
  begin
    open("#{$config.url}/robots.txt")

    puts('success')
  rescue Exception => ex
    log_console_exception(ex)

    puts('failed')
  end
end
