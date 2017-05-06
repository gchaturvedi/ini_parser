require_relative("./config_object")
require_relative("./exceptions")

module INI
  module ConfigSetting
    ##
    # This module basically converts a given setting value
    # to its respective type.
    extend self
    # Allow long/slightly complex method for readability purposes
    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    # rubocop:disable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
    def convert_to_type(value)
      if true_boolean?(value)
        return true
      elsif false_boolean?(value)
        return false
      elsif float?(value)
        converted_value = Float(value)
      elsif number?(value)
        converted_value = Integer(value)
      elsif path?(value)
        converted_value = value.strip
      elsif string?(value)
        converted_value = value.delete("\"").strip
      elsif array?(value)
        vals = value.split(",")
        converted_value = vals.map { |v| v.delete("\"").strip }
      elsif empty_setting?(value)
        fail INI::InvalidSetting, "Invalid or blank setting value \
        in config file: #{value}"
      else
        converted_value = value.strip
      end
      converted_value
    end
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
    # rubocop:enable Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
    def path?(val)
      !!(val =~ /\A\//)
    end

    def empty_setting?(val)
      val.nil? || val.strip.length == 0
    end

    def float?(val)
      if number?(val) && !(val.index(".").nil?)
        return true
      else
        return false
      end
    end

    def number?(val)
      return true if Float(val)
    rescue ArgumentError
      return false
    end

    def true_boolean?(val)
      val == "yes" || val == "true" || val == "1" ? true : false
    end

    def false_boolean?(val)
      val == "no" || val == "false" || val == "0" ? true : false
    end

    def array?(val)
      val.split(",").length > 1
    end

    def string?(val)
      !(val.index("\"").nil?)
    end
  end
end
