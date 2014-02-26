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
      expect(MyMongoid.configuration).to be_a(MyMongoid::Configuration)
      expect(MyMongoid.configuration).to be(MyMongoid::Configuration.instance)
    end
  end

  describe "MyMongoid.configure" do
    it "yield MyMongoid.configuration to a block" do
      expect { |b|
        MyMongoid.configure(&b)
      }.to yield_with_args(MyMongoid::Configuration)

      MyMongoid.configure do |config|
        expect(config).to eq(MyMongoid.configuration)
      end
    end
  end
end
