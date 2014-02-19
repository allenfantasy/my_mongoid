require 'my_mongoid/fields'

module MyMongoid
  module Document
    extend ActiveSupport::Concern

    include Fields

    # COPY
    included do
      MyMongoid.register_model(self)
    end

    def initialize(attrs = {})
      raise ArgumentError if !attrs.is_a? Hash
      #attrs ||= {}
      if !attrs.empty?
        attrs.each_pair do |key, value|
          write_attribute(key, value)
        end
      end
    end

    def attributes
      @attributes ||= {}
    end

    def read_attribute(key)
      # raise UnknownAttribute Error if key doesn't exist
      attributes[key]
    end

    def write_attribute(key, value)
      # raise UnknownAttribute Error if key doesn't exist
      attributes[key] = value
    end

    def new_record?
      true
    end

    module ClassMethods
      def is_mongoid_model?
        # refactor?
        true
      end
    end
  end
end
