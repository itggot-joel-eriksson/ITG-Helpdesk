# Tell bundler where to fetch gems
source 'https://rubygems.org'

# Tell heroku and bundler which version of ruby to use
ruby '2.2.3'

# Gems used by all environments (development, production & test)
gem 'sinatra'
gem 'sinatra-partial'
gem 'data_mapper'
gem 'slim'
gem 'tilt', '~> 1.4.1' #temporary fix
gem 'racksh'
gem 'rack-flash3', require: 'rack-flash'
gem 'google-api-client', '0.9', require: 'google/api_client/client_secrets'
gem 'unirest'
gem 'kramdown', require: 'kramdown'
gem 'pry'

# Used during local development (on your own machine)
group :development do

  # Use SQLite
  gem 'dm-sqlite-adapter', group: :development
  gem 'rerun'
  gem 'thin'

end

# Used during production (on Heroku), when your application is 'live'
group :production do

  # Use Postgresql
  gem 'dm-postgres-adapter', group: :production

end

# Used when running tests (rake test:[acceptance|models|routes])
group :test do

  gem 'rspec' # Use rspec to write tests
  gem 'capybara' # Use capybara to simulate a web browser (no javascript)
  gem 'selenium-webdriver' # Use selenium to programmatically control a web browser (javascript capable)

end
