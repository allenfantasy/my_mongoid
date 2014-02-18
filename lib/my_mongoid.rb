require "my_mongoid/version"
require "my_mongoid/document"

module MyMongoid
  extend self
  def models
    @models ||= []
  end

  def register_model(base)
    models.push(base) unless models.include?(base)
  end

end
