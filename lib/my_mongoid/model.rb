require "moped"
require "active_support/inflector"

module MyMongoid
  module Model
    extend ActiveSupport::Concern

    def save
      self.id ||= BSON::ObjectId.new
      self.class.collection.insert(self.to_document)
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

      def collection_name
        self.name.tableize
      end

      def collection
        MyMongoid.session[self.collection_name]
      end

      def instantiate(attr= {})
        model = self.new(attr)
        model.instance_variable_set(:@new_record, false)
        model
      end

      def find(attr)
        raise MyMongoid::RecordNotFoundError if attr.nil?
        attr = { "_id" => attr } unless attr.is_a?(Hash)
        raise MyMongoid::RecordNotFoundError if attr.count == 0
        query = self.collection.find(attr)
        raise MyMongoid::RecordNotFoundError if query.count == 0
        self.instantiate(query.first)
      end
    end
  end
end
