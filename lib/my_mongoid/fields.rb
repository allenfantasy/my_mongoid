require 'my_mongoid/field'

module MyMongoid
  module Fields
    extend ActiveSupport::Concern

    included do
      class_attribute :fields

      self.fields = {}

      field :_id, :as => :id
    end

    module ClassMethods
      def field(name, options = {})
        named = name.to_s
        aliased = options[:as]
        aliased = aliased.to_s if aliased

        # REFACTOR: validate
        raise DuplicateFieldError.new if self.fields.keys.include?(named)

        add_field(named, options)


        create_accessor(named, named)
        create_accessor(named, aliased) if aliased
      end

      def create_accessor(name, aliased)
        create_getter(name, aliased)
        create_setter(name, aliased)
      end

      def create_getter(name, aliased)
        define_method aliased do
          read_attribute(name)
        end
      end

      def create_setter(name, aliased)
        define_method "#{aliased}=" do |value|
          write_attribute(name, value)
        end
      end

      def add_field(name, options)
        field = field_for(name, options)
        fields[name] = field
      end

      def field_for(named, options)
        Field.new(named, options)
      end

    end
  end
end
