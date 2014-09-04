require 'multi_json'
require 'hashie'

module ActiveRecord
  module Coders
    class JSON
      def self.load(json)
        new.load(json)
      end

      def self.dump(json)
        new.dump(json)
      end

      def initialize(default = Hashie::Mash.new)
        @default = default
      end

      def dump(obj)
        obj.nil? ? (@default.nil? ? nil : to_json(@default)) : to_json(obj)
      end

      def load(json)
        json.nil? ? @default : from_json(json)
      end

      private
      def to_json(obj)
        MultiJson.dump(obj)
      end

      def from_json(json)
        convert_object MultiJson.load(json)
      end

      def convert_object(obj)
        case obj
        when Array
          obj.map { |member| convert_object(member) }
        else
          obj
        end
      end

    end
  end
end
