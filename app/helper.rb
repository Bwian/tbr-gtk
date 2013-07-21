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
  
  def do_about(window)
    about = Gtk::AboutDialog.new
    about.set_program_name "Telstra Bill Reporting"
    about.set_version "1.0"
    about.set_copyright "(c) Pyrrho Pty Ltd - 2013"
    about.set_comments "Telstra Bill Reporting parses Telstra billing files and produces individual and summary service reports.\n\nPlease note this version supports Telstra On Line Billing Service technical specification version 6.4\n"
    # about.set_website "www.pyrrho.com.au"
    about.set_logo(Gdk::Pixbuf.new("./images/logo.jpg",150,60))
    about.run
    about.destroy
  end  
  
  def config_path
    "#{base_directory}/config/services.csv"
  end
  
  def bill_path
    path = Dir.glob("#{base_directory}/data/*.{csv,CSV}").sort_by {|f| File.mtime(f)}.last
    path.nil? || path.empty? ? base_directory : path  
  end
  
  def base_directory
    exe = ENV["OCRA_EXECUTABLE"]
    exe.nil? || exe.empty? ? Dir.pwd : File.dirname(exe) 
  end
  
end