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

    it "should raise MyMongoid::UnconfiguredDatabaseError if host and database are not configured" do
      expect {
        MyMongoid.configuration.database = nil
        MyMongoid.session
      }.to raise_error(MyMongoid::UnconfiguredDatabaseError)
    end
  end
end
