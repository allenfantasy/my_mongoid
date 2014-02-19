require "active_support/core_ext"
require "active_support/json"
require "active_support/inflector"
require "active_support/time_with_zone"

require "my_mongoid/version"
require "my_mongoid/document"
require "my_mongoid/fields"
require "my_mongoid/errors"

module MyMongoid
  extend self
  def models
    @models ||= []
  end

  def register_model(base)
    models.push(base) unless models.include?(base)
  end

end
