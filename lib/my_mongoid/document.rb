require "my_mongoid/fields"
require "my_mongoid/attributes"
require "my_mongoid/model"

module MyMongoid
  module Document
    extend ActiveSupport::Concern

    include Fields
    include Attributes
    include Model

    # COPY
    included do
      MyMongoid.register_model(self)
    end

    def initialize(attrs = nil)
      attrs ||= {}
      raise ArgumentError if !attrs.is_a? Hash
      process_attributes(attrs)
      reset_changed_attributes
    end

    module ClassMethods
      def is_mongoid_model?
        # refactor?
        true
      end
    end
  end
end
