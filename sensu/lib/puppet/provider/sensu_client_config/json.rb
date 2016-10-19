require 'rubygems' if RUBY_VERSION < '1.9.0' && Puppet.version < '3'
require 'json' if Puppet.features.json?

begin
  require 'puppet_x/sensu/to_type'
rescue LoadError => e
  libdir = Pathname.new(__FILE__).parent.parent.parent.parent
  require File.join(libdir, 'puppet_x/sensu/to_type')
end

Puppet::Type.type(:sensu_client_config).provide(:json) do
  confine :feature => :json
  include Puppet_X::Sensu::Totype

  def conf
    begin
      @conf ||= JSON.parse(File.read(config_file))
    rescue
      @conf ||= {}
    end
  end

  def flush
    File.open(config_file, 'w') do |f|
      f.puts JSON.pretty_generate(conf)
    end
  end

  def config_file
    "#{resource[:base_path]}/client.json"
  end

  def create
    conf['client'] = {}
    self.client_name = resource[:client_name]
    self.address = resource[:address]
    self.bind = resource[:bind]
    self.port = resource[:port]
    self.subscriptions = resource[:subscriptions]
    self.safe_mode = resource[:safe_mode]
    self.custom = resource[:custom] unless resource[:custom].nil?
    self.keepalive = resource[:keepalive] unless resource[:keepalive].nil?
  end

  def destroy
    @conf = nil
  end

  def exists?
    conf.has_key?('client')
  end

  def check_args
    ['name', 'address', 'subscriptions', 'safe_mode', 'bind', 'keepalive', 'port', 'redact']
  end

  def client_name
    conf['client']['name']
  end

  def client_name=(value)
    conf['client']['name'] = value
  end

  def address
    conf['client']['address']
  end

  def address=(value)
    conf['client']['address'] = value
  end

  def bind
    conf['client']['bind']
  end

  def bind=(value)
    conf['client']['bind'] = value
  end

  def port
    conf['client']['port']
  end

  def port=(value)
    conf['client']['port'] = value
  end

  def subscriptions
    conf['client']['subscriptions'] || []
  end

  def subscriptions=(value)
    conf['client']['subscriptions'] = value
  end
  
  def redact
    conf['client']['redact'] || []
  end

  def redact=(value)
    conf['client']['redact'] = value
  end
  
  def custom
    conf['client'].reject { |k,v| check_args.include?(k) }
  end

  def custom=(value)
    conf['client'].delete_if { |k,v| not check_args.include?(k) }
    conf['client'].merge!(to_type(value))
  end

  def keepalive
    conf['client']['keepalive'] || {}
  end

  def keepalive=(value)
    conf['client']['keepalive'] = to_type(value)
  end

  def safe_mode
    conf['client']['safe_mode']
  end

  def safe_mode=(value)
    conf['client']['safe_mode'] = value
  end

end

