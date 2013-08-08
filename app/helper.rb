require 'gtk2'
require 'fileutils'
require_relative 'configure'
require_relative 'log_it'

class Helper
  
  DIRECTORY_STRUCTURE = [
    './config',
    './data/archive',
    './logs'
  ]
  
  def initialize
    @config = Configure.instance
  end
  
  def check_directory_structure
    DIRECTORY_STRUCTURE.each do |dir|
      return false unless Dir.exists?(dir)
    end 
    Dir.exists?(@config.archive) 
  end
  
  def fix_directory_structure
    build_directory(DIRECTORY_STRUCTURE)
    build_directory([@config.archive])
  end
  
  def services_path
    "#{base_directory}/config/services.csv"
  end
  
  def config_path
    "#{base_directory}/config/config.yaml"
  end
    
  def bill_path
    path = Dir["#{@config.data}/*.{csv,CSV}"].sort_by {|f| File.mtime(f)}.last
    path.nil? || path.empty? ? @config.data : path  
  end
  
  def base_directory
    exe = ENV["OCRA_EXECUTABLE"]
    exe = exe.gsub(/\\/,'/') unless exe.nil?
    exe.nil? || exe.empty? ? Dir.pwd : File.dirname(exe)
  end
  
  def init_config(type,filename)
    f = File.open(filename,'w')
    f.close
		@config.file = filename
    message = "#{type.capitalize} file #{filename} initialised."
    LogIt.instance.info(message)
  end
  
  def import_services(fname)
  	services = Services.new
		groups = Groups.new
    begin   	
      ParseFiles.map_services(groups,services,fname)
      FileUtils.cp(fname,services_path)
      LogIt.instance.info("Services configuration file installed from #{fname}")
    rescue Errno::ENOENT
      raise IOError, "Services configuration #{services_path} not found."
    end
    
    raise ArgumentError, "Services file invalid or empty.  #{fname} not installed as services.csv" if services.size == 0
  end 
  
  def yn(prompt,default)
    ans = 'x'
    while !(/[yn]/ =~ ans)
      print "#{prompt}: #{default}\C-h"
      ans = STDIN.gets.chomp
      ans = ans.empty? ? default : ans[0].downcase 
    end
      
    ans == 'y'
  end
  
  # Dialog helpers
  
  def csv_filters(chooser)
    filter1 = Gtk::FileFilter.new
    filter1.name = "CSV Files"
    filter1.add_pattern('*.csv')
    filter1.add_pattern('*.CSV')
    chooser.add_filter(filter1) # 1st added will be the default

    filter2 = Gtk::FileFilter.new
    filter2.name = "All Files"
    filter2.add_pattern('*')
    chooser.add_filter(filter2)
  end
  
  def do_info(window,message)
    dialog = Gtk::MessageDialog.new(window, 
                                    Gtk::Dialog::MODAL,
                                    Gtk::MessageDialog::INFO,
                                    Gtk::MessageDialog::BUTTONS_OK,
                                    message)
    dialog.run
    dialog.destroy
  end

  def do_error(window,message)
    dialog = Gtk::MessageDialog.new(window, 
                                    Gtk::Dialog::MODAL,
                                    Gtk::MessageDialog::ERROR,
                                    Gtk::MessageDialog::BUTTONS_OK,
                                    message)
    dialog.run
    dialog.destroy
  end
  
  def do_yn(window,message)
    dialog = Gtk::MessageDialog.new(window, 
                                    Gtk::Dialog::MODAL,
                                    Gtk::MessageDialog::ERROR,
                                    Gtk::MessageDialog::BUTTONS_YES_NO,
                                    message)
    response = dialog.run
    dialog.destroy
    response == Gtk::Dialog::RESPONSE_YES
  end
  
  def do_log_review(window,heading,filename)
    dialog = Gtk::Dialog.new(heading,
                             window,
                             Gtk::Dialog::MODAL,
                             [Gtk::Stock::CLOSE, Gtk::Dialog::RESPONSE_NONE])
  
    label = Gtk::Label.new(filename)
   
    buffer = Gtk::TextBuffer.new
    begin
      file = File.open(filename,'r')
      file.each_line do |line|
        buffer.insert(buffer.end_iter,line)
      end
      file.close
    rescue Errno::ENOENT
      buffer.text = "Unable to open file: #{filename}"
    end
    
    textview = Gtk::TextView.new(buffer)
    textview.editable = false
    textview.cursor_visible = false
    textview.indent = 10

    scrolledw = Gtk::ScrolledWindow.new
    scrolledw.border_width = 5
    scrolledw.add(textview)
    scrolledw.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_ALWAYS)

    dialog.vbox.pack_start(label,false,false,5)
    dialog.vbox.pack_start_defaults(scrolledw)
    dialog.resize(800,600)
    
    dialog.show_all
    dialog.run
    dialog.destroy
  end
  
  def do_services_review(window,heading,filename)
    dialog = Gtk::Dialog.new(heading,
                             window,
                             Gtk::Dialog::MODAL,
                             [Gtk::Stock::CLOSE, Gtk::Dialog::RESPONSE_NONE])
  
    label = Gtk::Label.new(filename)
    
    treestore = Gtk::TreeStore.new(String, String, String)

    services = Services.new
    groups = Groups.new
    services_file = services_path
    log = LogIt.instance
    
    begin
      ParseFiles.map_services(groups,services,services_file)
    rescue IOError
    rescue ArgumentError => e
      log.error(e.message)
      log.error(e.backtrace.inspect)
      do_error(window,"Error in services file #{services_file}.  See log for details.")
    end
    
    groups.each do |group|
      parent = treestore.append(nil)
      parent[0] = group.name
      group.each do |service|
        child = treestore.append(parent)
        phone = service.service_number
        phone = "#{phone[0..1]} #{phone[2..5]} #{phone[6..9]}" if phone[0] == '0'
        child[0] = phone
        child[1] = service.cost_centre
        child[2] = service.name
      end
    end

    view = Gtk::TreeView.new(treestore)
    view.enable_grid_lines = Gtk::TreeView::GRID_LINES_BOTH
    view.selection.mode = Gtk::SELECTION_NONE

    cols = ['Group','CC','Name']
    cols.each_index do |idx|
      renderer = Gtk::CellRendererText.new
      renderer.weight = Pango::FontDescription::WEIGHT_BOLD if idx == 0
      col = Gtk::TreeViewColumn.new(cols[idx], renderer, :text => idx)
      view.append_column(col)
    end
    
    scrolledw = Gtk::ScrolledWindow.new
    scrolledw.border_width = 5
    scrolledw.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_ALWAYS)
    scrolledw.add(view)
    
    dialog.vbox.pack_start(label,false,false,5)
    dialog.vbox.pack_start_defaults(scrolledw)
    dialog.resize(800,600)
    
    dialog.show_all
    dialog.run
    dialog.destroy
  end
  
  def do_import_services(window)
    dialog = Gtk::FileChooserDialog.new("Select new services File",
                                         window,
                                         Gtk::FileChooser::ACTION_OPEN,
                                         nil,
                                         [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL],
                                         [Gtk::Stock::OPEN, Gtk::Dialog::RESPONSE_ACCEPT])

    dialog.set_current_folder(@config.services)
    csv_filters(dialog)
    
    if dialog.run == Gtk::Dialog::RESPONSE_ACCEPT
      begin
        import_services(dialog.filename)
      ensure
        dialog.destroy  # pass through all exceptions but close dialog
      end
    else
      dialog.destroy 
    end
    
  end
  
  def do_edit_config(window)
    dialog = Gtk::Dialog.new('Edit Configuration',
                             window,
                             Gtk::Dialog::MODAL,
                             [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL],
                             [Gtk::Stock::OK, Gtk::Dialog::RESPONSE_ACCEPT])
                             
    @config.each do |key,value|
      input_label = Gtk::Label.new
      input_label.text = sprintf("%15s","#{key.capitalize}:")
    
      input = Gtk::Entry.new
      input.width_chars = 50
      input.text = value
      input.signal_connect('focus_out_event') do |w|   
        @config.send("#{key}=",input.text)
        input.select_region(0,0)
      end
                             
      chooser = Gtk::FileChooserButton.new("Select a directory", Gtk::FileChooser::ACTION_SELECT_FOLDER)
      chooser.current_folder = value
      chooser.signal_connect('selection_changed') do |w|
        input.text = chooser.filename
        @config.send("#{key}=",input.text)
      end
      
      hbox = Gtk::HBox.new(false, 5)
      hbox.pack_start(input_label,false,false,5)
      hbox.pack_start_defaults(input)
      hbox.pack_start(chooser,false,false,5)
      dialog.vbox.pack_start(hbox,false,false,5)
    end
      
    dialog.show_all
    if dialog.run == Gtk::Dialog::RESPONSE_ACCEPT
      @config.update
    else
      @config.reset
    end
    puts @config.inspect
    dialog.destroy
  end
  
  def do_about(window)
    about = Gtk::AboutDialog.new
    about.set_program_name "Telstra Bill Reporting"
    about.set_version "1.0"
    about.set_copyright "(c) Pyrrho Pty Ltd - 2013"
    about.set_comments "Telstra Bill Reporting parses Telstra billing files and produces individual and summary service reports.\n\nPlease note this version supports Telstra On Line Billing Service technical specification version 6.4\n"
    # about.set_website "www.pyrrho.com.au"
    about.set_logo(Gdk::Pixbuf.new("./images/logo_small.jpg"))
    about.run
    about.destroy
  end  
  
  def initialise_config(window,type,filename)
    if do_yn(window,"OK to overwrite #{type} file?")
      init_config(type,filename)
      do_info(window,"#{type.capitalize} file #{filename} set to zero length.")
    end
  end
  
  private
  
  def build_directory(dirs)
    dirs.each do |dir|
      FileUtils.mkpath(dir)
    end
  end
  
end
