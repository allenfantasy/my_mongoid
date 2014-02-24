describe MyMongoid::Field do
  let(:fklass) do
    MyMongoid::Field
  end

  let(:model) do
    fklass.new("public", { "default" => "okay" })
  end

  it "is a module" do
    expect(fklass).to be_a(Module)
  end

  describe "#name" do
    it "has name" do
      expect(model.name).to eq("public")
    end
  end

  describe "#options" do
    it "has options" do
      expect(model.options["default"]).to eq("okay")
    end
  end

end
