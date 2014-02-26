class TestModel
  include MyMongoid::Document
  field :hour
  field :minute
end

describe "should be able to create a record" do
  MyMongoid.configure do |config|
    config.host = "localhost:27017"
    config.database = "my_mongoid"
  end

  attr = { "_id" => 1, "hour" => 2, "minute" => "3" }

  describe "Model collection" do
    it "collection_name should use active support's titleize method" do
      expect(TestModel.collection_name).to eq(TestModel.name.tableize)
    end

    it "should return a model's collection" do
      expect(TestModel.collection).to be_a(Moped::Collection)
      expect(TestModel.collection.name).to eq(TestModel.name.tableize)
    end
  end

  describe "#to_document" do
    it "should return normal attributes hash" do
      testobj = TestModel.new(attr)
      expect(testobj.to_document).to eq(testobj.attributes)
    end

    it "could turn to bson form" do
      testobj = TestModel.new(attr)
      expect(testobj.to_document.to_bson).to be_a(String)
    end
  end

  describe "#save" do
    it "could save to db and return true" do
      lastcnt = TestModel.collection.find().count
      expect(TestModel.new.save).to be true
      expect(TestModel.collection.find().count - lastcnt).to eq(1)
    end

    it "Model#new_record? return false after saving" do
      testobj = TestModel.new
      expect(testobj.new_record?).to be true
      testobj.save
      expect(testobj.new_record?).to be false
    end

    describe "save with no id" do
      it "should generate a random id" do
        testobj = TestModel.new
        expect(testobj.id).to be_nil
        expect(testobj.save).to be true
        expect(testobj.id).to_not be_nil
        expect(TestModel.collection.find({"_id" => testobj.id}).count).to eq(1)
      end
    end
  end

  describe "model create" do
    it "should return a saved record" do
      TestModel.collection.drop
      testobj = TestModel.create(attr)
      expect(testobj).to be_a(TestModel)
      expect(testobj.new_record?).to be false
      expect(testobj.attributes).to eq(attr)
    end
  end

  describe "model instantiate" do
    it "should return a model instance and it is not new_record" do
      expect(TestModel.instantiate(attr)).to be_a(TestModel)
      expect(TestModel.instantiate.new_record?).to be false
    end

    it "should have given attributes" do
      TestModel.collection.drop
      expect(TestModel.instantiate(attr).attributes).to eq(attr)
    end
  end

  describe "model find" do
    before {
      TestModel.collection.drop
      TestModel.create(attr)
    }

    it "should be able to find a record by issuing query" do
      expect(TestModel.find(attr)).to be_a(TestModel)
      expect(TestModel.find(attr).new_record?).to be false
      expect(TestModel.find(attr).attributes).to eq(attr)
    end

    it "should be able to find a record by issuing shorthand id query" do
      expect(TestModel.find(1)).to be_a(TestModel)
      expect(TestModel.find(1).new_record?).to be false
      expect(TestModel.find(1).attributes).to eq(attr)
    end

    it "should raise Mongoid::RecordNotFoundError if nothing is found for an id" do
      expect {
        TestModel.find("2")
      }.to raise_error(MyMongoid::RecordNotFoundError)
    end
  end
end
