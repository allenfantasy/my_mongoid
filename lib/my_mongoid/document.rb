require "my_mongoid/fields"
require "my_mongoid/attributes"

module MyMongoid
  module Document
    extend ActiveSupport::Concern

    include Fields
    include Attributes

    # COPY
    included do
      MyMongoid.register_model(self)
    end

    def initialize(attrs = nil)
      attrs ||= {}
      raise ArgumentError if !attrs.is_a? Hash
      process_attributes(attrs)
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
