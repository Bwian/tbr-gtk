require 'gtk2'
require_relative 'process_bills'
require_relative 'helper'

def file_changed(chosen, field)
  field.text = chosen.filename ? chosen.filename : ''
  field.width_chars = field.text.length
end

helper = Helper.new

Dir.chdir(helper.base_directory)

window = Gtk::Window.new("Telstra Billing Reporter")
window.signal_connect('destroy') { Gtk.main_quit }
window.resize(400,400)

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
bill_file.width_chars = bill_file.text.length

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

mb = Gtk::MenuBar.new

filemenu = Gtk::Menu.new
filem = Gtk::MenuItem.new "File"
filem.set_submenu filemenu

exit = Gtk::MenuItem.new "Exit"
exit.signal_connect "activate" do
    Gtk.main_quit
end

filemenu.append exit
mb.append filem

config_file	= helper.config_path
process_bills = ProcessBills.new(textview,progress)

chooser.signal_connect('selection_changed') do |w|
  file_changed(chooser, bill_file)
end

button.signal_connect(:clicked) do |w|
  if !helper.check_directory_structure
    helper.do_error(window, "Error in directory structure: #{helper.base_directory}\nRebuild with 'File > Rebuild directory structure")
  elsif !File.exists?(helper.config_path)
    helper.do_error(window, "Missing configuration file: #{helper.config_path} \nInitialise with 'File > Initialise config file'")
  elsif !File.exists?(bill_file.text)
    helper.do_error(window, "Missing billing file: #{bill_file.text}")
  else
    w.sensitive = false 
    process_bills.run(config_file,bill_file.text)
    w.sensitive = true
  
    helper.do_info(window,"Processing billing file finished") 
  end
end

hbox = Gtk::HBox.new(false, 5)
hbox.pack_start(input_label,false,false,5)
hbox.pack_start_defaults(bill_file)
hbox.pack_start(chooser,false,false,5)

vbox = Gtk::VBox.new(false, 5)
vbox.border_width = 10
vbox.pack_start(hbox,false,false,5)
vbox.pack_start(button,false,false,5)
vbox.pack_start_defaults(scrolledw)
vbox.pack_start(progress,false,false,5)

mainbox = Gtk::VBox.new(false, 0)
mainbox.pack_start(mb,false,false,0)
mainbox.pack_start_defaults(vbox)

window.add(mainbox)
window.show_all

Gtk.main
