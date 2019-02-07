source 'http://rubygems.org'

gem 'activerecord', '>= 3.2', '< 4.2'
gem 'multi_json'

# v11 has a removed method that rspec-core < 3.4.4 uses.
# See: https://stackoverflow.com/questions/35893584/nomethoderror-undefined-method-last-comment-after-upgrading-to-rake-11
gem 'rake', '< 11.0'

group :development, :test do
  gem 'rspec', '~> 2.0'
  gem 'pg', '~> 0.20.0'
end

group :development do
  gem 'rubocop'
  gem 'rdoc'
  gem 'bundler'
  gem 'jeweler'
end
