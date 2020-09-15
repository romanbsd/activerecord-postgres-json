# frozen_string_literal: true

require 'active_record'
require 'active_record/connection_adapters/postgresql_adapter'

module ActiveRecord
  module ConnectionAdapters
    # jsonb type isn't known by Rails 3.2.x, 4.0.x and 4.1.x, so the gem is defining it
    PostgreSQLAdapter::NATIVE_DATABASE_TYPES[:jsonb] = { name: 'jsonb' }

    if ActiveRecord.respond_to?(:version)
      if ::ActiveRecord.version >= Gem::Version.new('4.0.0') && ::ActiveRecord.version < Gem::Version.new('4.2.0')
        # As suggested here:
        # http://www.innovationontherun.com/fixing-unknown-oid-geography-errors-with-postgis-and-rails-4-0/
        # to prevent the Rails 4.0/4.1 error of "unknown OID: {field}"
        PostgreSQLAdapter::OID.register_type('jsonb', PostgreSQLAdapter::OID::Identity.new)
      end
    elsif ActiveRecord::VERSION::MAJOR == 3 && ActiveRecord::VERSION::MINOR == 2
      # json type isn't known by Rails 3.2.x, so the gem is defining it.
      # Rails 4.0.x and 4.1.x already have it defined
      PostgreSQLAdapter::NATIVE_DATABASE_TYPES[:json]  = { name: 'json' }
    end

    class PostgreSQLColumn < Column
      # Adds the json type for the column.
      def simplified_type_with_json(field_type)
        case field_type
        when 'json'
          :json
        when 'jsonb'
          :jsonb
        else
          simplified_type_without_json(field_type)
        end
      end

      alias_method_chain :simplified_type, :json

      class << self
        def extract_value_from_default_with_json(default)
          case default
          when "'{}'::json", "'{}'::jsonb"
            '{}'
          when "'[]'::json", "'[]'::jsonb"
            '[]'
          else
            extract_value_from_default_without_json(default)
          end
        end

        alias_method_chain :extract_value_from_default, :json
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

      def jsonb(*args)
        options = args.extract_options!
        column_names = args
        column_names.each { |name| column(name, 'jsonb', options) }
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

      def jsonb(*args)
        options = args.extract_options!
        column_names = args
        column_names.each { |name| column(name, 'jsonb', options) }
      end
    end
  end
end
