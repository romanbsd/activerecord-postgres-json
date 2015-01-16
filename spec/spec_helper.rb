$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rspec'
require 'active_record'
require 'activerecord-postgres-json'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
# Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.around db: true do |example|
    if example.metadata[:disable_transactions]
      example.call
    else
      ActiveRecord::Base.transaction do
        begin
          example.call
        ensure
          raise ActiveRecord::Rollback
        end
      end
    end
  end
end
