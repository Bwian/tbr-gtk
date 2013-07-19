require 'logger'
require 'singleton'
require 'gtk2'

class LogIt < Logger
	include Singleton

	def to_file(fname)
  	file = File.open(fname,'a')
  	@logdev = Logger::LogDevice.new(file)
  end
  
  def to_stdout
    @logdev = Logger::LogDevice.new(STDOUT)
  end
  
  def to_stderr
    @logdev = Logger::LogDevice.new(STDERR)
  end
  
  def to_null
  	file = File.open('/dev/null','a')
  	@logdev = Logger::LogDevice.new(file)
  end
  
  def textview=(textview)
    @textview = textview
  end
  
  def add(severity, message, progname)
    super(severity, message, progname)
    
    if @textview
      @textview.buffer.insert(@textview.buffer.end_iter,"#{@severity[severity]}#{progname}\n")
      @textview.scroll_to_iter(@textview.buffer.end_iter,0.0,false,0,0)
      refresh
    end
  end
  
	private
		
  def initialize
		super('/dev/null')
    @textview = nil
    
    @severity = Hash.new
    @severity[Logger::UNKNOWN]  = ''
    @severity[Logger::DEBUG]    = ''
    @severity[Logger::INFO]     = ''
    @severity[Logger::WARN]     = 'Warning - '
    @severity[Logger::ERROR]    = 'Error - '
    @severity[Logger::FATAL]    = 'Fatal - '
  end
  
  def refresh
    while Gtk.events_pending? do
      Gtk.main_iteration
    end
  end
end