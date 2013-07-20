module TempConfig
  require 'tempfile'
  require 'yaml'

  def setup
    @config_file = Tempfile.new 'snooper_config'
  end

  def teardown
    @config_file.unlink
  end

  def write_config(config)
    @config_file.open
    @config_file.truncate 0
    YAML.dump config, @config_file
    @config_file.close
  end
end
