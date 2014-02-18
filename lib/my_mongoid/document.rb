module MyMongoid
  module Document

    def self.included(base)
      base.extend ClassMethods
      MyMongoid.register_model(base)
    end
    module ClassMethods
      def is_mongoid_model?
        # refactor?
        true
      end
    end
  end
end
