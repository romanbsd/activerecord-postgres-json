require 'logger'
require 'pg'

db_config = YAML.load_file(File.expand_path('../../database.yml', __FILE__))

begin
  ActiveRecord::Base.establish_connection db_config['test']
  ActiveRecord::Base.connection.active?
rescue Exception => e
  encoding = db_config['test']['encoding'] || ENV['CHARSET'] || 'utf8'
  begin
    ActiveRecord::Base.establish_connection(db_config['test'].merge('database' => 'postgres', 'schema_search_path' => 'public'))
    ActiveRecord::Base.connection.create_database(db_config['test']['database'], db_config['test'].merge('encoding' => encoding))
    ActiveRecord::Base.establish_connection(db_config['test'])
  rescue Exception => ec
    $stderr.puts ec, *(ec.backtrace)
    $stderr.puts "Couldn't create database for #{db_config['test'].inspect}"
  end
ensure
  ActiveRecord::Base.logger = Logger.new(STDOUT)
  ActiveRecord::Base.logger.formatter = ->(_, _, _, msg) { "#{msg}\n" }
end