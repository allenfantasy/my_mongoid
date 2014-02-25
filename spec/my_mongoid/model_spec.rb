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
      expect(MyMongoid::Model.collection_name(TestModel)).to eq(TestModel.name.tableize)
    end

    it "should return a model's collection" do
      expect(MyMongoid::Model.collection(TestModel)).to be_a(Moped::Collection)
    end
  end
end