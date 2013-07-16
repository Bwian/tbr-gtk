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
  
end