require 'gtk2'

class Helper
  
  DIRECTORY_STRUCTURE = [
    ['config'],
    ['data','archive'],
    ['logs']
  ]
  
  def check_directory_structure
    DIRECTORY_STRUCTURE.each do |dir|
      dname = "./#{dir.join('/')}"
      return false unless Dir.exists?(dname)
    end  
    true
  end
  
  def fix_directory_structure
    root = Dir.getwd
    DIRECTORY_STRUCTURE.each do |dir|
      Dir.chdir(root)
      dir.each do |sub|
        subname = "./#{sub}"
        Dir.mkdir(subname) unless Dir.exists?(subname)
        Dir.chdir(subname)
      end
    end
    Dir.chdir(root)
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
    # view.enable_tree_lines = true
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
  
  def services_path
    "#{base_directory}/config/services.csv"
  end
  
  def config_path
    "#{base_directory}/config/config.yaml"
  end
  
  def bill_path
    path = Dir["#{base_directory}/data/*.{csv,CSV}"].sort_by {|f| File.mtime(f)}.last
    path.nil? || path.empty? ? base_directory : path  
  end
  
  def base_directory
    exe = ENV["OCRA_EXECUTABLE"]
    exe = exe.gsub(/\\/,'/') unless exe.nil?
    exe.nil? || exe.empty? ? Dir.pwd : File.dirname(exe)
  end
  
end
