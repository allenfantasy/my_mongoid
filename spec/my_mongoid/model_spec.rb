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

  describe "Should be able to update a record" do
    describe "#changed_attributes" do
      it "should be an empty hash initially" do
        expect(TestModel.new(attr).changed_attributes).to eq({})
      end

      it "should track writes to attributes" do
        testobj = TestModel.new(:hour => 1)
        testobj.attributes = { "_id" => 1, "hour" => 2, "minute" => "3" }
        expect(testobj.changed_attributes).to eq({ "_id" => [nil, 1], "hour" => [1, 2], "minute" => [nil, "3"] })
        testobj.hour = 1
        expect(testobj.changed_attributes).to eq({ "_id" => [nil, 1], "minute" => [nil, "3"] })
      end

      it "should not make a field dirty if the assigned value is equaled to the old value" do
        testobj = TestModel.new(:hour => 1)
        testobj.hour = 1
        expect(testobj.changed_attributes.empty?).to be true
        testobj.hour = 2
        expect(testobj.changed_attributes.empty?).to be false
        testobj.hour = 1
        expect(testobj.changed_attributes.empty?).to be true
      end
    end

    describe "#changed?" do
      it "should be false for a newly instantiated record" do
        expect(TestModel.new(attr).changed?).to be false
      end

      it "should be true if a field changed" do
        testobj = TestModel.new(:hour => 1)
        testobj.hour = 1
        expect(testobj.changed?).to be false
        testobj.hour = 2
        expect(testobj.changed?).to be true
        testobj.hour = 1
        expect(testobj.changed?).to be false
      end
    end

    describe "#save" do
      it "should have no changes right after persisting" do
        testobj = TestModel.new
        testobj.minute = 1
        expect(testobj.changed?).to be true
        testobj.save
        expect(testobj.changed?).to be false
      end

      it "should save the changes if a document is already persisted" do
        testobj = TestModel.create(:hour => 1)
        testobj.hour = 2
        id = testobj._id
        testobj.save
        expect(TestModel.find(id).hour).to eq(2)
      end
    end

    describe "#atomic_updates" do
      it "should return {} if nothing changed" do
        expect(TestModel.instantiate(attr).atomic_updates).to eq({})
      end

      it "should return {} if record is not a persisted document" do
        testobj = TestModel.new(:hour => 1)
        expect(testobj.atomic_updates).to eq({})
        testobj.hour = 2
        expect(testobj.atomic_updates).to eq({})
        testobj.save
        testobj.hour = 3
        expect(testobj.atomic_updates).not_to eq({})
      end

      it "should generate the $set update operation to update a persisted document" do
        testobj = TestModel.instantiate(:hour => 1)
        testobj.hour = 2
        expect(testobj.atomic_updates["$set"]).to eq({"hour" => 2})
      end

      it "should ignore change on _id" do
        testobj = TestModel.instantiate(:_id => 1)
        testobj.hour = 1
        testobj._id = 10
        expect(testobj.atomic_updates["$set"]).to eq({"hour" => 1})
      end
    end

    describe "#update_document" do
      it "should not issue query if nothing changed" do
        expect_any_instance_of(Moped::Query).to_not receive(:update)
        TestModel.create(:hour => 1).update_document
      end

      it "should update the document in database if there are changes" do
        testobj = TestModel.create(:hour => 1)
        testobj.hour = 2
        id = testobj._id
        expect(testobj.changed?).to be true
        testobj.update_document
        expect(TestModel.find(id).hour).to eq(2)
        expect(testobj.changed?).to be false
      end
    end

    describe "#update_attributes" do
      it "should change and persiste attributes of a record" do
        testobj = TestModel.create(:hour => 1)
        id = testobj._id
        testobj.update_attributes({"hour" => 2, "minute" => 3})
        expect(TestModel.find(id).hour).to eq(2)
        expect(TestModel.find(id).minute).to eq(3)
        TestModel.collection.drop
        testobj = TestModel.new(:hour => 1, :_id => 1)
        id = testobj._id
        testobj.update_attributes({"hour" => 2, "minute" => 3})
        expect(TestModel.find(id).hour).to eq(2)
        expect(TestModel.find(id).minute).to eq(3)
      end

      it "require a hash arg" do
        expect {
          TestModel.new.update_attributes(1)
        }.to raise_error(ArgumentError)
      end

      it "should ignore change on _id" do
        TestModel.collection.drop
        testobj = TestModel.new(:hour => 1, :_id => 1)
        id = testobj._id
        testobj.update_attributes({"hour" => 2, "_id" => 3})
        expect(TestModel.find(id).hour).to eq(2)
      end

      it "throw exception for unknown field" do
        expect {
          TestModel.new.update_attributes("no" => 1)
        }.to raise_error(MyMongoid::UnknownAttributeError)
      end
    end

    describe "#delete" do
      it "should delete a record from db" do
        expect {
          testobj = TestModel.create({"hour" => 1})
          testobj.delete
          TestModel.find(testobj.id)
        }.to raise_error(MyMongoid::RecordNotFoundError)
      end
    end

  end
end
