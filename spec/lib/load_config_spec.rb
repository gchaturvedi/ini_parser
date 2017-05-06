describe 'load_config' do
  before(:each) do
    @config_obj = load_config "spec/fixtures/correct_sample.ini"
  end

  it 'should return a ConfigObject that can be queried' do
    expect(Object.send(:load_config, "spec/fixtures/correct_sample.ini", [])).to be_a INI::ConfigObject
  end

  describe "should return an object with query capabilities with a correct file" do
    it "should return a config object with a hash" do
      expect(@config_obj.common).not_to eq(nil)
      expect(@config_obj.common.class).to eq(CustomConfigHash)
      expect(@config_obj.common.basic_size_limit).to eq(262_144_00)
      expect(@config_obj.ftp).not_to eq(nil)
      expect(@config_obj.http).not_to eq(nil)
    end

    it "should return symbols for keys in the hashes" do
      expect(@config_obj.common[:basic_size_limit]).to eq(262_144_00)
    end

    it "should return nil and not error out for queries that don't match any data" do
      expect(@config_obj.common.bar).to eq(nil)
      expect(@config_obj.hagrid).to eq(nil)
    end
  end

  describe "should properly handle overrides" do
    it "should use the override if passed in as a symbol or string" do
      override_config = load_config "spec/fixtures/correct_sample.ini", [:itscript, "production"]
      expect(override_config.common).not_to eq(nil)
      expect(override_config.common.path).to eq("/srv/tmp/itscript")
      expect(override_config.http.path).to eq("/srv/var/tmp/prod")
    end

    it "should use the last override defined in the file if multiple are passed in" do
      override_config_multiple = load_config "spec/fixtures/correct_sample.ini", ["ubuntu", :production]
      expect(override_config_multiple.ftp).not_to eq(nil)
      expect(override_config_multiple.ftp.path).to eq("/etc/var/uploads/ubuntu")
    end
  end

  describe "should properly return all boolean types" do
    it "should return a config object with correct boolean types" do
      bool_config = load_config "spec/fixtures/various_bools.ini"
      expect(bool_config.bools).not_to eq(nil)
      expect(bool_config.bools.yes).to eq(true)
      expect(bool_config.bools.no).to eq(false)
      expect(bool_config.bools.one).to eq(true)
      expect(bool_config.bools.zero).to eq(false)
      expect(bool_config.bools.false).to eq(false)
      expect(bool_config.bools.true).to eq(true)
    end
  end

  describe "should properly return all numeric types" do
    it "should return a config object with correct numeric types" do
      num_config = load_config "spec/fixtures/numeric.ini"
      expect(num_config.numeric).not_to eq(nil)
      expect(num_config.numeric.floater).to eq(1.23)
      expect(num_config.numeric.floater.class).to eq(Float)
      expect(num_config.numeric.intval).to eq(100)
      expect(num_config.numeric.intval.class).to eq(Fixnum)
    end
  end
end
