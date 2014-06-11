ActiveSupport.on_load :active_record do
  require 'activerecord-postgres-json/activerecord'
end
require 'activerecord-postgres-json/coders'
