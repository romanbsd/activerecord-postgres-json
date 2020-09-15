require 'logger'
require 'pg'
require 'yaml'

db_config = YAML.load_file(File.expand_path('../../database.yml', __FILE__))
structure_sql_filename = 'db/ar_postgre_json_test.sql'

begin
  ActiveRecord::Base.establish_connection db_config['test']
  ActiveRecord::Base.connection.active?
rescue Exception => _e
  encoding = db_config['test']['encoding'] || ENV['CHARSET'] || 'utf8'
  begin
    ActiveRecord::Base.establish_connection(db_config['test'].merge('database' => 'postgres', 'schema_search_path' => 'public'))
    ActiveRecord::Base.connection.recreate_database(db_config['test']['database'], db_config['test'].merge('encoding' => encoding))
    ActiveRecord::Base.establish_connection(db_config['test'])

    ActiveRecord::Base.configurations = db_config
    if ActiveRecord.respond_to?(:version)
      require 'active_record/tasks/database_tasks'

      if ::ActiveRecord.version >= Gem::Version.new('4.1.0') && ::ActiveRecord.version < Gem::Version.new('4.2.0')
        ActiveRecord::Tasks::DatabaseTasks.load_schema_current(:sql, structure_sql_filename, 'test')
      elsif ::ActiveRecord.version >= Gem::Version.new('4.0.0') && ::ActiveRecord.version < Gem::Version.new('4.1.0')
        ActiveRecord::Tasks::DatabaseTasks.structure_load(db_config['test'], structure_sql_filename)
      end
    elsif ActiveRecord::VERSION::MAJOR == 3 && ActiveRecord::VERSION::MINOR == 2
      require "active_record/base"
      require "rake"
      require "rake/dsl_definition"
      load "active_record/railties/databases.rake"

      set_psql_env(db_config)
      `psql -f "#{structure_sql_filename}" #{db_config['test']['database']}`
    end

  rescue Exception => ec
    $stderr.puts ec, *(ec.backtrace)
    $stderr.puts "Couldn't create database for #{db_config['test'].inspect}"
  end
ensure
  ActiveRecord::Base.logger = Logger.new(STDOUT)
  ActiveRecord::Base.logger.formatter = ->(_, _, _, msg) { "#{msg}\n" }
end
