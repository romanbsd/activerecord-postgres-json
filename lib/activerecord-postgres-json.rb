ActiveSupport.on_load :active_record do # rubocop:disable Style/FileName
  require 'activerecord-postgres-json/activerecord'
end
require 'activerecord-postgres-json/coders'
