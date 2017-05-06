describe INI::Parser do
  before(:each) do
    @parser = INI::Parser.new('spec/fixtures/blank.ini')
    @correct_line = '[group]'
  end

  describe '#group?' do
    it 'should return true for a line that is a proper [group]' do
      expect(@parser.send(:group?, @correct_line)).to eq(true)
    end

    it 'should return false for a line that is not a valid group' do
      line = '<frodo>'
      expect(@parser.send(:group?, line)).to eq(false)
    end
  end

  describe '#strip_inline_comments' do
    it 'should strip inline comments from a line' do
      expect(@parser.send(:strip_inline_comments, "hello ; a comment")).to eq("hello")
    end
  end

  describe 'with bad config files' do
    it 'should raise a failure if no groups are specified in the config file' do
      parser_no_groups = INI::Parser.new('spec/fixtures/only_settings.ini')
      expect { parser_no_groups.send(:process_file) }.to raise_error(INI::MalformedFile)
    end

    it 'should raise a failure if there is a malformed key/val setting in the config file' do
      parser_malformed = INI::Parser.new('spec/fixtures/only_settings.ini')
      expect { parser_malformed.send(:process_file) }.to raise_error(INI::MalformedFile)
    end

    it 'should raise a failure with no key' do
      parser_malformed = INI::Parser.new('spec/fixtures/bad_key.ini')
      expect { parser_malformed.send(:process_file) }.to raise_error(INI::MalformedFile)
    end

    it 'should raise a failure with a key but no value' do
      parser_malformed = INI::Parser.new('spec/fixtures/bad_setting.ini')
      expect { parser_malformed.send(:process_file) }.to raise_error(INI::MalformedFile)
    end

    it 'should raise a failure if duplicate groups exist' do
      parser_malformed = INI::Parser.new('spec/fixtures/duplicate_groups.ini')
      expect { parser_malformed.send(:process_file) }.to raise_error(INI::MalformedFile)
    end
  end
end
