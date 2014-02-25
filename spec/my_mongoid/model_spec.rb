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
      expect(TestModel.new.collection_name).to eq(TestModel.name.tableize)
    end

    it "should return a model's collection" do
      expect(TestModel.new.collection).to be_a(Moped::Collection)
    end
  end

  describe "#to_document" do
    #TODO confused with this case. Howard says test this method to return a bson
    it "should return a normal hash" do
      expect(TestModel.new.to_document).to be_a(Hash)
    end
  end

  describe "#save" do
    #TODO how to verify doc is written to db?
    it "could save to db and return true" do
      expect(TestModel.new.save).to be true
    end

    it "should make Model#new_record return false" do
      testobj = TestModel.new
      expect(testobj.new_record?).to be true
      testobj.save
      expect(testobj.new_record?).to be false
    end
  end

  describe "model create" do
    it "should return a saved record" do
      testobj = TestModel.create(:hour => 1)
      expect(testobj).to be_a(TestModel)
      expect(testobj.new_record?).to be false
    end
  end
end
