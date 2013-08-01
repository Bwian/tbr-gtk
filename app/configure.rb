require 'yaml'
require 'singleton'
require_relative 'log_it'

class Configure
  include Singleton
  
  def file=(fname)
    config(fname)
  end
  
  def update
    file = File.open(@filename,'w')
    @config.each_pair do |key,value|
      file.write(sprintf("%-15s:%s\n",key,value))
    end
    file.close
    @clone = @config.clone
  end
  
  def changed?
    !@config.eql?(@clone)
  end
  
  private
  
  def initialize
    super
    config(nil)
  end
  
  def config(filename)
    log = LogIt.instance
    @config = nil
    begin
      @filename = filename.nil? || filename.empty? ? './config.haml' : filename
      @config = YAML.load_file(@filename)
    rescue Errno::ENOENT
      log.warn("Missing configuration file '#{@filename}'. Using default configuration.")
    rescue Psych::SyntaxError
      log.warn("Syntax error in configuration file '#{@filename}'. Using default configuration.")
    end
    
    @config = {:data => './data', :archive => './data/archive'} unless @config
    
    @config.each_pair do |key,value|
      self.class.send(:define_method, key) { @config[key] }
      self.class.send(:define_method, "#{key}=") {|param| @config[key] = param }   
    end

    @clone = @config.clone
  end
end