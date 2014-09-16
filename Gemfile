source 'https://rubygems.org'

gem 'rails', '3.2.8'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '3.2.6'
  gem 'coffee-rails', '3.2.2'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', '0.12.0', :platforms => :ruby

  gem 'uglifier', '2.2.1'
end

gem 'jquery-rails', '2.3.0'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'

gem 'will_paginate', '3.0.5'
gem 'authlogic', '3.3.0'
gem 'prawn', '0.12.0'
gem 'prawnto_2', '0.2.6', :require => 'prawnto'
if RUBY_PLATFORM=~ /mingw32/ 
  gem 'mysql2', '0.3.11'
else
  gem 'mysql2', '0.3.13'
end

group :development, :test do
  gem 'rails-erd'
  gem 'i18n_generators'
end

