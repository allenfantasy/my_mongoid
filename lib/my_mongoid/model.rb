require "moped"
require "active_support/inflector"

module MyMongoid
  module Model
    def collection_name
      self.class.name.tableize
    end

    def collection
      MyMongoid.session[self.collection_name]
    end
  end
end
