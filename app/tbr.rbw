require 'gtk2'

require_relative 'process_bills'
require_relative 'helper'
require_relative 'configure'
require_relative 'log_it'
require_relative 'progress_it'

LOGFILE = './logs/telstra.log'

def file_changed(chosen, field)
  field.text = chosen.filename if chosen.filename
  field.width_chars = field.text.length
  field.select_region(0,0)
end

def dummy_menu(helper,window)
  helper.do_info(window,'Menu option not yet implemented')
end

helper = Helper.new
services_file	= helper.services_path
config_file = helper.config_path
config = Configure.new(config_file)
log = LogIt.instance
log.to_file(LOGFILE) # Initialise logging
replace = false  # Replace previous run's directory

Dir.chdir(helper.base_directory)

window = Gtk::Window.new("Telstra Billing Reporter")
window.signal_connect('destroy') { Gtk.main_quit }
window.resize(400,400)

chooser = Gtk::FileChooserButton.new(
  "Choose a Billing File", Gtk::FileChooser::ACTION_OPEN)
chooser.current_folder = "#{helper.base_directory}/data"

filter1 = Gtk::FileFilter.new
filter1.name = "CSV Files"
filter1.add_pattern('*.csv')
filter1.add_pattern('*.CSV')
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
ProgressIt.instance.bar = progress

textview = Gtk::TextView.new
textview.editable = false
textview.cursor_visible = false
textview.indent = 10
log.textview = textview

scrolledw = Gtk::ScrolledWindow.new
scrolledw.border_width = 5
scrolledw.add(textview)
scrolledw.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_ALWAYS)

accel_group = Gtk::AccelGroup.new

# File Menu
file_menu = Gtk::Menu.new
file_mi = Gtk::MenuItem.new "File"
file_mi.set_submenu file_menu

rebuild_mi = Gtk::MenuItem.new "Rebuild directory structure"
rebuild_mi.signal_connect "activate" do
  if helper.check_directory_structure
    helper.do_info(window,'Directory structure OK')
  else
    helper.fix_directory_structure
    helper.do_info(window,'Directory structure rebuilt')
  end
end

delete_mi = Gtk::MenuItem.new "Delete current reports"
delete_mi.signal_connect "activate" do
  replace = true
  helper.do_info(window,'Report directory will be replaced in next run.')
end

exit_mi = Gtk::MenuItem.new "Exit"
exit_mi.signal_connect "activate" do
  Gtk.main_quit
end

file_separator = Gtk::MenuItem.new nil

file_menu.append rebuild_mi
file_menu.append delete_mi
file_menu.append file_separator
file_menu.append exit_mi

# Edit Menu
edit_menu = Gtk::Menu.new
edit_mi = Gtk::MenuItem.new "Edit"
edit_mi.set_submenu edit_menu

cut_mi = Gtk::ImageMenuItem.new(Gtk::Stock::CUT, accel_group)
cut_mi.signal_connect "activate" do
  bill_file.cut_clipboard
end

copy_mi = Gtk::ImageMenuItem.new(Gtk::Stock::COPY, accel_group)
copy_mi.signal_connect "activate" do
  bill_file.copy_clipboard
end

paste_mi = Gtk::ImageMenuItem.new(Gtk::Stock::PASTE, accel_group)
paste_mi.signal_connect "activate" do
  bill_file.paste_clipboard
end

edit_menu.append cut_mi
edit_menu.append copy_mi
edit_menu.append paste_mi

# Configuration Menu
configuration_menu = Gtk::Menu.new
configuration_mi = Gtk::MenuItem.new "Configuration"
configuration_mi.set_submenu configuration_menu

servicesfile_mi = Gtk::MenuItem.new "Review services file"
servicesfile_mi.signal_connect "activate" do
  helper.do_services_review(window,'Services Configuration File Review', services_file)
end

import_services_mi = Gtk::MenuItem.new "Import services file"
import_services_mi.signal_connect "activate" do
	helper.do_info(window,"Import services file not yet implemented")
	# helper.do_import_services(window,'Edit Configuration File', config_file)
end

init_config_mi = Gtk::MenuItem.new "Initialise configuration file"
init_config_mi.signal_connect "activate" do
  if helper.do_yn(window,'OK to overwrite configuration file?')
    f = File.open(config_file,'w')
    f.close
		config = Configure.new(config_file)
    helper.do_info(window,"Configuration file #{config_file} initialised.")
  end
end

configfile_mi = Gtk::MenuItem.new "Edit configuration file"
configfile_mi.signal_connect "activate" do
  helper.do_info(window,"Edit configuration file not yet implemented")
	# helper.do_edit_config(window,'Edit Configuration File', config_file)
end

configuration_separator = Gtk::MenuItem.new nil

configuration_menu.append servicesfile_mi
configuration_menu.append import_services_mi
configuration_menu.append configuration_separator
configuration_menu.append init_config_mi
configuration_menu.append configfile_mi

# Logs Menu
logs_menu = Gtk::Menu.new
logs_mi = Gtk::MenuItem.new "Logs"
logs_mi.set_submenu logs_menu

logfile_mi = Gtk::MenuItem.new "Review log file"
logfile_mi.signal_connect "activate" do
  helper.do_log_review(window,'Log File Review',File.expand_path(LOGFILE))
end

init_log_mi = Gtk::MenuItem.new "Initialise logfile"
init_log_mi.signal_connect "activate" do
  if helper.do_yn(window,'OK to reset logfile?')
    f = File.open(LOGFILE,'w')
    f.close
    helper.do_info(window,"Configuration file #{LOGFILE} set to zero length.")
  end
end

logs_menu.append logfile_mi
logs_menu.append init_log_mi

# Help Menu
help_menu = Gtk::Menu.new
help_mi = Gtk::MenuItem.new "Help"
help_mi.set_submenu help_menu

about_mi = Gtk::MenuItem.new "About"
about_mi.signal_connect "activate" do
  helper.do_about(window)
end

help_menu.append about_mi

mb = Gtk::MenuBar.new
mb.append file_mi
mb.append edit_mi
mb.append configuration_mi
mb.append logs_mi
mb.append help_mi

process_bills = ProcessBills.new

chooser.signal_connect('selection_changed') do |w|
  file_changed(chooser, bill_file)
end

button.signal_connect(:clicked) do |w|
  if !helper.check_directory_structure
    helper.do_error(window, "Error in directory structure: #{helper.base_directory}\nRebuild with 'File > Rebuild directory")
  elsif File.directory?(bill_file.text) || !File.exists?(bill_file.text)
    helper.do_error(window, "Missing billing file: #{bill_file.text}")
  else
		if !File.exists?(services_file)
		  f = File.open(services_file,'w')
			f.close
		end
			
		textview.buffer.text = ''
    w.sensitive = false 
    begin
      process_bills.run(services_file,bill_file.text,replace)
      helper.do_info(window,"Processing billing file finished")
    rescue IOError => e
      log.error(e.message)
      log.error(e.backtrace.inspect)
      helper.do_error(window,e.message)
    rescue ArgumentError => e
      log.error(e.message)
      log.error(e.backtrace.inspect)
      helper.do_error(window,"Possible error in billing file #{bill_file.text}.  See log for details.")
    end 
    w.sensitive = true
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
button.grab_focus

Gtk.main