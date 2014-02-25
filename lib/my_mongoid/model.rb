require "moped"
require "active_support/inflector"

module MyMongoid
  module Model
    extend ActiveSupport::Concern

    def collection_name
      self.class.name.tableize
    end

    def collection
      MyMongoid.session[self.collection_name]
    end

    def save
      self.collection.insert(self.to_document)
      @new_record = false
      true
    end

    def new_record?
      @new_record = true if @new_record.nil?
      @new_record
    end

    module ClassMethods
      def create(attr = {})
        model = self.new(attr)
        model.save
        model
      end
    end
  end
end
