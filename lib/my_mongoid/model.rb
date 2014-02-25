require "moped"
require "active_support/inflector"

module MyMongoid
  class Model
    def self.collection_name(model)
      model.name.tableize
    end

    def self.collection(model)
      MyMongoid.session[self.collection_name(model)]
    end
  end
end
