require 'heroku-api'

module HerokuTools
  class HerokuTools
    def self.scale_workers(worker, qty)
      return if (!Rails.env.beta? && !Rails.env.production?) || !$config.heroku_workers.include?(worker)

      heroku = Heroku::API.new(:api_key => $config.heroku_api_key)

      heroku.post_ps_scale($config.heroku_app_name, worker, qty)

      log_console("SCALING #{worker} to #{qty}")
    end
  end
end
