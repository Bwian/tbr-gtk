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
      return false if !Dir.exists?(dname)
    end  
    true
  end
  
  def fix_directory_structure
    root = Dir.getwd
    DIRECTORY_STRUCTURE.each do |dir|
      Dir.chdir(root)
      dir.each do |sub|
        subname = "./#{sub}"
        Dir.mkdir(subname) if !Dir.exists?(subname)
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
                                    Gtk::Dialog::DESTROY_WITH_PARENT,
                                    Gtk::MessageDialog::INFO,
                                    Gtk::MessageDialog::BUTTONS_OK,
                                    message)
    dialog.run
    dialog.destroy
  end

  def do_error(window,message)
    dialog = Gtk::MessageDialog.new(window, 
                                    Gtk::Dialog::DESTROY_WITH_PARENT,
                                    Gtk::MessageDialog::ERROR,
                                    Gtk::MessageDialog::BUTTONS_OK,
                                    message)
    dialog.run
    dialog.destroy
  end
  
  def do_yn(window,message)
    dialog = Gtk::MessageDialog.new(window, 
                                    Gtk::Dialog::DESTROY_WITH_PARENT,
                                    Gtk::MessageDialog::ERROR,
                                    Gtk::MessageDialog::BUTTONS_YES_NO,
                                    message)
    response = dialog.run
    dialog.destroy
    response == Gtk::Dialog::RESPONSE_YES
  end
  
  def config_path
    "#{base_directory}/config/services.csv"
  end
  
  def bill_path
    path = Dir.glob("#{base_directory}/data/*.csv").sort_by {|f| File.mtime(f)}.last
    path.nil? || path.empty? ? base_directory : path  
  end
  
  def base_directory
    exe = ENV["OCRA_EXECUTABLE"]
    exe.nil? || exe.empty? ? Dir.pwd : File.dirname(exe) 
  end
  
end