source 'https://rubygems.org'

#ruby
ruby '2.1.5'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.8'

# Use postgres as the database for Active Record
gem 'pg', '0.17.1'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails', '~> 3.1.1'
gem 'jquery-ui-rails', '~> 5.0.0'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
#gem 'spring',        group: :development

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
gem 'unicorn', '~> 4.8.3'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

# heroku
if ENV['NOT_HEROKU'].nil? # must use NOT_HEROKU because env not available in heroku compile
  gem 'rails_12factor', '~> 0.0.2', group: [:production, :beta]
  
  # deflater
  gem 'heroku-deflater', '~> 0.5.3'
end

gem 'heroku-api', '~> 0.3.19'

# bootstrap
gem 'bootstrap-sass', '~> 3.2.0.1'
gem 'autoprefixer-rails', '~> 3.0.0.20140821'

# rabl
gem 'rabl', '~> 0.9.3'

# oj - needed for rabl
gem 'oj', '~> 2.7.2'

# swagger
gem 'swagger-docs', '0.1.8'

# aws
gem 'aws-sdk', '~> 1.59.0'

# google api
gem 'google-api-client', '~> 0.7.1'

# rest-client
gem 'rest-client', '~> 1.7.2'

# mail
gem 'mail', '~> 2.5.4'

# backbone
#gem 'backbone-rails', '~> 1.1.2'
gem 'rails-backbone', '~> 1.1.2', git:'https://github.com/codebrew/backbone-rails'
gem 'backbone-validation-rails', '~> 0.7.1.1'

# ejs
gem 'ejs', '~> 1.1.1'

# rails testing
# keep in development for generators
group :development, :test do
  gem 'rspec-rails', '~> 3.0.1'
  gem 'factory_girl_rails', '4.4.1'
end

group :test do
  gem 'capybara', '~> 2.4.1'
  gem 'capybara-webkit', '~> 1.3.0'
  gem 'database_cleaner', '~> 1.3.0'
end

# Backbone testing framework
group :development, :test do
  gem 'phantomjs', '~> 1.9.7.1'
  gem 'teaspoon', '~> 0.8.0'
  gem 'sinon-rails', '~> 1.10.3'
  gem 'jasmine-sinon-rails', '~> 1.3.4'
end

# premailer
gem 'premailer', '~> 1.8.2'

# delayed job
gem 'delayed_job', '~> 4.0.4'
gem 'delayed_job_active_record', '~> 4.0.2'

# gmail oauth
gem 'gmail_xoauth', '~> 0.4.1'
