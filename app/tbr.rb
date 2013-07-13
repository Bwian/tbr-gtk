require 'gtk2'

def file_changed(chosen, field)
  field.text = chosen.filename ? chosen.filename : ''
  field.width_chars = field.text.length
end

window = Gtk::Window.new("Telstra Billing Reporter")
window.border_width = 20
window.signal_connect('destroy') { Gtk.main_quit }
window.resize(600,400)

chooser = Gtk::FileChooserButton.new(
    "Choose a Billing File", Gtk::FileChooser::ACTION_OPEN)

input_label = Gtk::Label.new
input_label.text = 'File path:'

input = Gtk::Entry.new
input.text = 'telstra.csv'

button = Gtk::Button.new('Begin processing')

buffer = Gtk::TextBuffer.new
textview = Gtk::TextView.new(buffer)

scrolledw = Gtk::ScrolledWindow.new
scrolledw.border_width = 5
scrolledw.add(textview)
scrolledw.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_ALWAYS)

chooser.signal_connect('selection_changed') do |w|
  file_changed(chooser, input)
end

button.signal_connect(:clicked) do |w|
  # button.sensitive = false
  puts "clicked"
  buffer.text = 'Line 1'
  sleep 2
  buffer.insert(buffer.end_iter,"Line 2")
  # button.sensitive = true
end

filter1 = Gtk::FileFilter.new
filter2 = Gtk::FileFilter.new
filter1.name = "CSV Files"
filter2.name = "All Files"
filter1.add_pattern('*.csv')
filter2.add_pattern('*')
chooser.add_filter(filter1) # 1st added will be the default
chooser.add_filter(filter2)

hbox = Gtk::HBox.new(false, 5)
hbox.pack_start(input_label,false,false,5)
hbox.pack_start_defaults(input)
hbox.pack_start(chooser,false,false,5)

vbox = Gtk::VBox.new(false, 5)
vbox.pack_start(hbox,false,false,5)
vbox.pack_start(button,false,false,5)
vbox.pack_start_defaults(scrolledw)
window.add(vbox)
window.show_all

Gtk.main
