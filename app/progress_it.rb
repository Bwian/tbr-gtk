require 'singleton'
require 'gtk2'

class ProgressIt
	attr_accessor :total, :bar
  attr_reader   :count
  
  include Singleton

  def zero
    @count = 0
  end
  
  def increment
    @count += 1
    @bar.fraction = @count.to_f/@total if @bar
    refresh
  end
  
	private
		
  def initialize
    @total = 100
    @count = 0
    @bar = nil
  end
  
  def refresh
    while Gtk.events_pending? do
      Gtk.main_iteration
    end
  end
end