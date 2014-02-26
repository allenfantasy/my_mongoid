class TestModel
  include MyMongoid::Document
  field :hour
end

describe "should be able to create a record" do
  MyMongoid.configure do |config|
    config.host = "localhost:27017"
    config.database = "my_mongoid"
  end

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
    testobj = TestModel.new(:hour => 1)
    it "should return normal attributes hash" do
      expect(testobj.to_document).to eq(testobj.attributes)
    end

    it "could turn to bson form" do
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
  end

  describe "model create" do
    it "should return a saved record" do
      testobj = TestModel.create("hour" => 1)
      expect(testobj).to be_a(TestModel)
      expect(testobj.new_record?).to be false
      expect(testobj.attributes).to eq("hour" => 1)
    end
  end
end
