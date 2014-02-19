require 'my_mongoid/field'

module MyMongoid
  module Fields
    extend ActiveSupport::Concern

    # COPY
    included do
      class_attribute :fields

      self.fields = {}

      field :_id
    end

    module ClassMethods
      # COPY
      def field(name)
        named = name.to_s
        # validate
        raise DuplicateFieldError.new if self.fields.keys.include?(named)

        add_field(named)
        create_getter(named)
        create_setter(named)
      end

      def create_getter(name)
        define_method name do
          read_attribute(name)
        end
      end

      def create_setter(name)
        define_method "#{name}=" do |value|
          write_attribute(name, value)
        end
      end

      def add_field(name)
        field = field_for(name)
        fields[name] = field
      end

      def field_for(named)
        Field.new(named)
      end

    end
  end
end
