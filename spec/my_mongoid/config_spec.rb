describe "Should be able to configure MyMongoid:" do
  describe "MyMongoid::Configuration" do
    testobj = MyMongoid::Configuration.instance

    it "is a singleton class" do
      expect {
        MyMongoid::Configuration.new
      }.to raise_error(NoMethodError)
      expect(MyMongoid::Configuration.instance).to be(MyMongoid::Configuration.instance)
    end

    it "have #host accessor" do
      expect(testobj.respond_to?(:host)).to be true
      expect(testobj.respond_to?(:host=)).to be true
    end

    it "have #database accessor" do
      expect(testobj.respond_to?(:database)).to be true
      expect(testobj.respond_to?(:database=)).to be true
    end
  end

  describe "MyMongoid.configuration" do
    it "return the single instance of MyMongoid::Configuration" do
      expect(MyMongoid.configuration).to be(MyMongoid::Configuration.instance)
    end
  end

  describe "MyMongoid.configure" do
    it "yield MyMongoid.configuration to a block" do
      MyMongoid.configure do |config|
        config.database = "my_mongoid"
        config.host = "localhost:27017"
      end
      expect(MyMongoid.configuration.database).to eq("my_mongoid")
      expect(MyMongoid.configuration.host).to eq("localhost:27017")
    end
  end
end
