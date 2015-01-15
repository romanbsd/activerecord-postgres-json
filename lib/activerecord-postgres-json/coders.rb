require 'multi_json'

module ActiveRecord
  module Coders
    class JSON
      def self.load(json)
        new.load(json)
      end

      def self.dump(json)
        new.dump(json)
      end

      def initialize(params = {})
        @default = {}
        return unless params.class.name == 'Hash'
        @default   = params[:default] if params[:default]
        @symbolize_keys = params[:symbolize_keys] if params[:symbolize_keys]
      end

      def dump(obj)
        if obj.nil?
          @default.nil? ? nil : to_json(@default)
        else
          to_json(obj)
        end
      end

      def load(json)
        json.nil? ? @default : from_json(json)
      end

      private

      def to_json(obj)
        MultiJson.dump(obj)
      end

      def from_json(json)
        convert_object MultiJson.load(json, symbolize_keys: @symbolize_keys)
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
