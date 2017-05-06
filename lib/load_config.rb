require_relative "./parser"
require_relative "./config_object"

##
# The load_config method as listed in
# the challenge requirements
def load_config(file_path, overrides = [])
  parser = INI::Parser.new(file_path, overrides)
  parser.process_file
  INI::ConfigObject.new(parser.config_vals)
end
