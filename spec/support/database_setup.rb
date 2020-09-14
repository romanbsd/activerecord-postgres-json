require 'active_record/tasks/database_tasks'
require 'logger'
require 'pg'
require 'yaml'

db_config = YAML.load_file(File.expand_path('../../database.yml', __FILE__))

begin
  ActiveRecord::Base.establish_connection db_config['test']
  ActiveRecord::Base.connection.active?
rescue Exception => _e
  encoding = db_config['test']['encoding'] || ENV['CHARSET'] || 'utf8'
  begin
    ActiveRecord::Base.establish_connection(db_config['test'].merge('database' => 'postgres', 'schema_search_path' => 'public'))
    ActiveRecord::Base.connection.recreate_database(db_config['test']['database'], db_config['test'].merge('encoding' => encoding))
    ActiveRecord::Base.establish_connection(db_config['test'])

    ActiveRecord::Base.configurations       = db_config
    ActiveRecord::Tasks::DatabaseTasks.load_schema_current(:sql, 'db/ar_postgre_json_test.sql', 'test')
  rescue Exception => ec
    $stderr.puts ec, *(ec.backtrace)
    $stderr.puts "Couldn't create database for #{db_config['test'].inspect}"
  end
ensure
  ActiveRecord::Base.logger = Logger.new(STDOUT)
  ActiveRecord::Base.logger.formatter = ->(_, _, _, msg) { "#{msg}\n" }
end
