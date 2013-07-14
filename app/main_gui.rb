require 'gtk2'
require_relative 'log_it'

class MainGUI

  def initialize(textview,progress)
    @textview = textview
    @progress = progress
    @log = LogIt.instance
    @log.to_file('./logs/telstra.log')
    @log.textview = textview 
  end
  
  def run   
    @textview.buffer.text = ''
    @log.info("Starting Telstra Billing Data Extract")
    sleep 1
    (1..30).each do |i|
      @progress.fraction = i/30.0
      sleep 0.2
      @log.info("Line #{i}")
    end
  end
  
end