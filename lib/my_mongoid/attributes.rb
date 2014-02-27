module MyMongoid
  module Attributes
    def attributes
      @attributes ||= {}
    end

    def read_attribute(key)
      raise UnknownAttributeError unless self.fields.has_key?(key)
      attributes[key]
    end

    def write_attribute(key, value)
      raise UnknownAttributeError unless self.fields.has_key?(key)
      track_changed_attributes(key, value, attributes[key])
      attributes[key] = value
    end

    def process_attributes(attrs = nil)
      attrs ||= {}
      if !attrs.empty?
        attrs.each_pair do |key, value|
          name = key.to_s
          # REFACTOR
          raise UnknownAttributeError unless self.class.instance_methods.map! { |i| i.to_s }.include?("#{name}=")
          self.send("#{name}=", value)
        end
      end
    end

    def to_document
      self.attributes
    end

    alias :attributes= :process_attributes

  end
end
