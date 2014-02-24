class Temp
  include MyMongoid::Fields
end

describe MyMongoid::Fields do
  let(:klass) do
    Temp
  end

  let(:model) do
    Temp.new
  end

  describe ".field" do
    context "when declare same field name for more than once" do
      it "should raise DuplicateFieldError" do
      end
    end

    context "create accessor" do
      before :all do
        class Temp
          field :public
        end
      end

      describe "#create_getter" do
        it "should respond to getter" do
          klass.new.should respond_to(:public)
        end
      end
      describe "#create_setter" do
        it "should respond to setter" do
          klass.new.should respond_to(:public=)
        end
      end
    end

  end

  describe "included" do
    it "has default id field" do
      expect(klass.new).to respond_to(:id)
      expect(klass.new).to respond_to(:id=)
    end

    it "has default _id field as alias" do
      expect(klass.new).to respond_to(:_id)
      expect(klass.new).to respond_to(:_id=)
    end
  end

end
