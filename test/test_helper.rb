require 'minitest/autorun'
require'fileutils'
 
require_relative '../app/helper'

class TestHelper < MiniTest::Test 
  
  def setup
    @helper = Helper.new
  end
  
  def test_correct_directory_structure
    assert(@helper.check_directory_structure)   
  end
  
  def test_wrong_directory_structure
    Dir.chdir('./test')
    refute(@helper.check_directory_structure)
    Dir.chdir('../')
  end
  
  def test_fix_directory_structure
    FileUtils.rm_rf('./tmp')
    Dir.mkdir('./tmp')
    Dir.chdir('./tmp')
    @helper.fix_directory_structure
    assert(@helper.check_directory_structure)
    Dir.chdir('../')
    FileUtils.rm_rf('./tmp')
  end
  
end
