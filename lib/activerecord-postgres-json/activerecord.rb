require 'active_record'
require 'active_record/connection_adapters/postgresql_adapter'

module ActiveRecord

  module ConnectionAdapters
    PostgreSQLAdapter::NATIVE_DATABASE_TYPES[:json] = {name: 'json'}

    class PostgreSQLColumn < Column
      # Adds the json type for the column.
      def simplified_type_with_json(field_type)
        field_type == 'json' ? :json : simplified_type_without_json(field_type)
      end

      alias_method_chain :simplified_type, :json
    end
  end

  class TableDefinition

    # Adds json type for migrations. So you can add columns to a table like:
    #   create_table :people do |t|
    #     ...
    #     t.json :info
    #     ...
    #   end
    def json(*args)
      options = args.extract_options!
      column_names = args
      column_names.each { |name| column(name, 'json', options) }
    end

  end

  class Table

    # Adds json type for migrations. So you can add columns to a table like:
    #   change_table :people do |t|
    #     ...
    #     t.json :info
    #     ...
    #   end
    def json(*args)
      options = args.extract_options!
      column_names = args
      column_names.each { |name| column(name, 'json', options) }
    end
  end

end
