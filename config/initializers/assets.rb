Rails.application.config.assets.precompile += %w( application-home.css )
Rails.application.config.assets.precompile += %w( application-home.js )
Rails.application.config.assets.precompile += %w( home/colors/mediumaquamarine.css )

if Rails.env.development? || Rails.env.test?
  Rails.application.config.assets.precompile += %w( teaspoon.css )
  Rails.application.config.assets.precompile += %w( jasmine/1.3.1.js )
  Rails.application.config.assets.precompile += %w( teaspoon-jasmine.js )
  Rails.application.config.assets.precompile += %w( teaspoon-teaspoon.js )
end
