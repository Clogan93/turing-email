require 'heroku-api'

module HerokuTools
  class HerokuTools
    def self.scale_dynos(dyno, qty)
      return if (!Rails.env.beta? && !Rails.env.production?) || !$config.heroku_dynos.include?(dyno)

      heroku = Heroku::API.new(:api_key => $config.heroku_api_key)

      heroku.post_ps_scale($config.heroku_app_name, dyno, qty)

      log_console("SCALING #{dyno} to #{qty}")
    end
    
    def self.count_dynos(dyno)
      return if (!Rails.env.beta? && !Rails.env.production?) || !$config.heroku_dynos.include?(dyno)

      heroku = Heroku::API.new(:api_key => $config.heroku_api_key)

      result = heroku.get_ps($config.heroku_app_name)
      
      num_dynos = 0
      result.body.each do |dyno|
        parts = dyno["process"].split(".")
        
        num_dynos += 1 if parts[0] == dyno
      end
      
      return num_dynos
    end
  end
end
