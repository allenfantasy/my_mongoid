module MyMongoid
  module Attributes
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

    def process_attributes(attrs = nil)
      attrs ||= {}
      if !attrs.empty?
        attrs.each_pair do |key, value|
          name = key.to_s
          # REFACTOR
          raise UnknownAttributeError unless self.class.fields.keys.include?(name)
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
