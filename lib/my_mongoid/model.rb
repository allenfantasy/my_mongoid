require "moped"
require "active_support/inflector"

module MyMongoid
  module Model
    extend ActiveSupport::Concern

    def save
      self.id ||= BSON::ObjectId.new
      begin
        self.class.find(self.id)
        update_document
      rescue MyMongoid::RecordNotFoundError
        self.class.collection.insert(self.to_document)
      end
      @new_record = false
      reset_changed_attributes
      true
    end

    def delete
      self.class.collection.find("_id" => self.id).remove_all
    end

    def new_record?
      @new_record = true if @new_record.nil?
      @new_record
    end

    def changed?
      !changed_attributes.empty?
    end

    # TODO Changed attribute cannot be tracked by:
    # Expose @attributes so that it is directly written
    # Field assignment method is overriden
    def changed_attributes
      @changed_attributes ||= {}
    end

    def atomic_updates
      return {} if new_record?
      change = {}
      changed_attributes.each do |attr, cg|
        change[attr] = cg[1]
      end
      change.delete("_id")
      change.empty? ? {} : { "$set" => change }
    end

    def update_document
      self.class.collection.find({ "_id" => self.id }).update(atomic_updates) unless atomic_updates.empty?
    end

    def update_attributes(attr)
      raise ArgumentError unless attr.is_a?(Hash)
      attr.delete("_id")
      self.attributes = attr
      self.save
    end

    private
    def track_changed_attributes(key, value, oldvalue)
      # its caller ensures key is a valid field, will not check again
      if changed_attributes.has_key?(key)
        changed_attributes[key][1] = value
      else
        changed_attributes[key] = [oldvalue, value]
      end
      changed_attributes.delete(key) if value == changed_attributes[key][0]
    end

    def reset_changed_attributes
      @changed_attributes = {}
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
