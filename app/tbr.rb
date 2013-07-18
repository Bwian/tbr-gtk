require 'gtk2'
require_relative 'process_bills'
require_relative 'helper'

def file_changed(chosen, field)
  field.text = chosen.filename ? chosen.filename : ''
  field.width_chars = field.text.length
end

helper = Helper.new

window = Gtk::Window.new("Telstra Billing Reporter")
window.border_width = 20
window.signal_connect('destroy') { Gtk.main_quit }
window.resize(600,400)

chooser = Gtk::FileChooserButton.new(
  "Choose a Billing File", Gtk::FileChooser::ACTION_OPEN)

filter1 = Gtk::FileFilter.new
filter1.name = "CSV Files"
filter1.add_pattern('*.csv')
chooser.add_filter(filter1) # 1st added will be the default

filter2 = Gtk::FileFilter.new
filter2.name = "All Files"
filter2.add_pattern('*')
chooser.add_filter(filter2)

input_label = Gtk::Label.new
input_label.text = 'File path:'

bill_file = Gtk::Entry.new
bill_file.text = helper.bill_path

button = Gtk::Button.new('Begin processing')

progress = Gtk::ProgressBar.new

textview = Gtk::TextView.new
textview.editable = false
textview.cursor_visible = false
textview.indent = 10

scrolledw = Gtk::ScrolledWindow.new
scrolledw.border_width = 5
scrolledw.add(textview)
scrolledw.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_ALWAYS)

config_file	= helper.config_path

process_bills = ProcessBills.new(textview,progress)

chooser.signal_connect('selection_changed') do |w|
  file_changed(chooser, bill_file)
end

button.signal_connect(:clicked) do |w|
# TODO: Check files OK.
  
  w.sensitive = false 
  process_bills.run(config_file,bill_file.text)
  w.sensitive = true
  
  helper.do_info(window,"Processing billing file finished")
end

hbox = Gtk::HBox.new(false, 5)
hbox.pack_start(input_label,false,false,5)
hbox.pack_start_defaults(bill_file)
hbox.pack_start(chooser,false,false,5)

vbox = Gtk::VBox.new(false, 5)
vbox.pack_start(hbox,false,false,5)
vbox.pack_start(button,false,false,5)
vbox.pack_start_defaults(scrolledw)
vbox.pack_start(progress,false,false,5)

window.add(vbox)
window.show_all

Gtk.main
