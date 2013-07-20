module TestUtils
  def self.silent
    require 'stringio'
    out = StringIO.new
    begin
      save = $stdout
      $stdout = out
      yield
    ensure
      $stdout = save
    end
    out
  end

  module MockConfig
    def self.new(options)
      o = {
        :base_path => Dir.pwd,
        :command => 'true',
        :paths => [Dir.pwd],
        :filters => [],
        :ignored => [],
        :hooks => []
      }.merge! options
      Struct.new(*o.keys).new(*o.values)
    end
  end

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
end
