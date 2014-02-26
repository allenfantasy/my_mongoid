describe "Should be able to get database session" do

  MyMongoid.configure do |config|
    config.host = "localhost:27017"
    config.database = "my_mongoid"
  end

  describe "MyMongoid.session" do
    it "should return a Moped::Session" do
      expect(MyMongoid.session).to be_a(Moped::Session)
    end

    it "should memoize the session @session" do
      expect(MyMongoid.session).to be(MyMongoid.session)
    end

    it "should raise MyMongoid::UnconfiguredDatabaseError if host or database are not configured" do
      expect {
        MyMongoid.configuration.database = nil
        MyMongoid.configuration.host = "localhost:999"
        MyMongoid.session
      }.to raise_error(MyMongoid::UnconfiguredDatabaseError)
      expect {
        MyMongoid.configuration.database = "test"
        MyMongoid.configuration.host = ""
        MyMongoid.session
      }.to raise_error(MyMongoid::UnconfiguredDatabaseError)
    end
  end
end
