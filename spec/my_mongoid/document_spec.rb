class Event
  include MyMongoid::Document
end

describe MyMongoid::Document do
  it "is a module" do
    expect(MyMongoid::Document).to be_a(Module)
  end

  let(:klass) do
    Event
  end

  let(:dummy) do
    Event.new("dummy")
  end

  let(:model) do
    Event.new(:public => "okay")
  end

  let(:unknown) do
    Event.new(:unknown => "test")
  end

  describe ".new" do

    context "when attr is nil" do
      it "should not raise any Errors" do
      end
    end

    context "when attr is not a Hash" do
      it "should raise an 'ArgumentError'" do
        expect {
          dummy
        }.to raise_error(ArgumentError)
      end
    end

    context "when attr Hash has unknown attributes" do
      it "should raise an 'UnknownAttributeError'" do
        expect {
          unknown
        }.to raise_error(MyMongoid::UnknownAttributeError)
      end
    end

    context "when all attributes are valid" do
      before do
        klass.send :field, :public
      end

      it "model should have attribute value" do
        expect(model.public).to eq("okay")
      end
    end
  end

  describe "#new_record?" do
    it "all new records should return true" do
      expect(Event.new).to be_new_record
    end
  end

  describe ".included" do
    it "MyMongoid should have klass" do
      expect(MyMongoid.models).to include(klass)
    end
  end

end
