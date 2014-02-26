require "moped"

module MyMongoid
  def session
    config = self.configuration
    raise MyMongoid::UnconfiguredDatabaseError unless config.valid?
    @session ||= {}
    @session[config.host] ||= Moped::Session.new([config.host])
    @session[config.host].use(config.database)
    @session[config.host]
  end
end
