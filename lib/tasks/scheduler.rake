require 'open-uri'

desc "This task is called by the Heroku scheduler add-on"

task :keep_dyno_alive => :environment do
  begin
    open($config.url)
    puts('success')
  rescue
    puts('failed')
  end
end
