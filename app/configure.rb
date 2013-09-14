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
    @config.each do |key,value|
      file.write(sprintf("%-15s%s\n","#{key}:",value))
    end
    file.close
    @clone = @config.clone
  end
  
  def changed?
    !@config.eql?(@clone)
  end
  
  def reset
    @config = @clone.clone
  end
  
	def each(&blk)
  	@config.each(&blk)
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
      @filename = filename.nil? || filename.empty? ? '' : filename
      @config = YAML.load_file(@filename)
    rescue Errno::ENOENT
      log.warn("Missing configuration file '#{@filename}'. Using default configuration.") unless @filename.empty?
    rescue Psych::SyntaxError
      log.warn("Syntax error in configuration file '#{@filename}'. Using default configuration.")
    end
    
    @config = {
      :input    => './data', 
      :output   => './data', 
      :archive  => './data/archive',
      :services => './config' 
    } unless @config
    
    @config.each do |key,value|
      self.class.send(:define_method, key) { @config[key] }
      self.class.send(:define_method, "#{key}=") {|param| @config[key] = param }   
    end

    @clone = @config.clone
  end
end