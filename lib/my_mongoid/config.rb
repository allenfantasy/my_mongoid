require "singleton"

module MyMongoid
  class Configuration
    include ::Singleton

    attr_accessor :host
    attr_accessor :database

    def valid?
      !(@host.nil? || @host.empty? || @database.nil? || @database.empty?)
    end
  end

  def configuration
    Configuration.instance
  end

  def configure(&config_method)
    config_method.call(MyMongoid.configuration)
  end
end
