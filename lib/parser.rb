require_relative "./config_setting"
require_relative "./custom_config_hash"
require_relative "./exceptions"

module INI
  ##
  # The Parser class has the responsibility of
  # parsing the configuration file and returning the
  # data in a hash format.  It will use the File.foreach
  # method of parsing the file one line at a time so
  # it doesn't load the entire file into memory for
  # efficiency.
  class Parser
    attr_reader :config_vals

    def initialize(path, overrides = [])
      @path = path
      @overrides = overrides.map(&:to_s)
      @config_vals = CustomConfigHash.new
    end

    def process_file
      File.foreach(@path) do |line|
        next if new_line_or_comment?(line)
        line = strip_inline_comments(line)
        parse_line(line)
      end
    end

    private

    def parse_line(line)
      if group?(line)
        parse_group_line(line)
      else
        parse_regular_line(line)
      end
    end

    def new_line_or_comment?(line)
      (line.strip.empty? || !!(line =~ /^;/))
    end

    def parse_group_line(line)
      line = line.strip
      group_name = group(line).to_sym
      if @config_vals.include?(group_name)
        fail INI::MalformedFile, "Duplicate groups in config file"
      else
        @current_group = group_name
        @config_vals[@current_group.to_sym] = CustomConfigHash.new
      end
    end

    def parse_regular_line(line)
      validate_regular_line(line)
      split_values = line.split("=")
      key = split_values[0].strip
      val = split_values[1].strip
      if override_setting?(key)
        update_override_if_enabled(val, key)
      else
        setting_value = INI::ConfigSetting.convert_to_type(val)
        @config_vals[@current_group.to_sym][key.to_sym] = setting_value
      end
    end

    def override_setting?(key)
      if !!(key =~ /<(\w+)\>$/)
        return (key.count("<") == key.count(">"))
      else
        return false
      end
    end

    def update_override_if_enabled(val, key_with_override)
      key_setting = key_with_override[/^[^\<]*/, 0]
      override_name = key_with_override[/<(\w+)\>$/, 0].delete("<").delete(">")
      return unless @overrides.include?(override_name)
      @config_vals[@current_group.to_sym][key_setting.to_sym] = val
    end

    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def validate_regular_line(line)
      if line.index("=").nil?
        fail INI::MalformedFile, "Malformed line in the config file: #{line}"
      end
      split_line = line.split("=").reject(&:empty?)
      if split_line.length > 2
        fail INI::MalformedFile, "Malformed line in the config file: #{line}"
      elsif @current_group.nil?
        fail INI::MalformedFile, "No groups specified in the config file"
      elsif split_line.length == 1 || split_line.length == 0
        fail INI::MalformedFile, "Blank key or setting value"
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

    def strip_inline_comments(val)
      val.sub(/;.*$/, "").strip
    end

    def group?(line)
      line = line.strip
      !!(line =~ /^\[(\w+)\]$/)
    end

    def group(line)
      line =~ /^\[(\w+)\]$/
      line.gsub(/[\[\]]/, '')
    end
  end
end
