require "moped"

module MyMongoid
  def session
    config = self.configuration
    raise MyMongoid::UnconfiguredDatabaseError if config.database.nil? || config.database.empty?
    @session ||= {}
    @session[config.host] ||= Moped::Session.new([config.host])
    @session[config.host].use(config.database)
    @session[config.host]
  end
end
