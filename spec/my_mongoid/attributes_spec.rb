class AnotherEvent
  include MyMongoid::Document
end

describe MyMongoid::Attributes do

  let(:klass) do
    AnotherEvent
  end

  let(:model) do
    klass.new(:public => "okay")
  end

  describe "#attributes" do
    it "should be a Hash" do
      expect(klass.new.attributes).to be_a(Hash)
    end
  end

  describe "#read_attribute" do
    before do
      klass.send :field, :public
    end
    it "should read existing attribute" do
      expect(model.read_attribute("public")).to eq("okay")
    end
  end
end
