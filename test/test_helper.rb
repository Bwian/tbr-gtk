require 'minitest/autorun'
require'fileutils'
 
require_relative '../app/helper'
require_relative '../app/configure'

class TestHelper < MiniTest::Test 
  
  def setup
    @helper = Helper.new
    @config = Configure.instance
    @config.file = './test/data/test.yaml'
  end
  
  def teardown
    @config.file = nil  # reset configuration for subsequent tests
  end
  
  def test_correct_directory_structure
    assert(@helper.check_directory_structure)   
  end
  
  def test_wrong_directory_structure
    Dir.chdir('./test')
    refute(@helper.check_directory_structure)
    Dir.chdir('../')
  end
  
  def test_invalid_archive_directory
    @config.archive = './data/missing'
    refute(@helper.check_directory_structure)
  end
  
  def test_fix_directory_structure
    @config.archive = './data/archive'
    FileUtils.rm_rf('./tmp')
    Dir.mkdir('./tmp')
    Dir.chdir('./tmp')
    @helper.fix_directory_structure
    assert(@helper.check_directory_structure)
    Dir.chdir('../')
    FileUtils.rm_rf('./tmp')
  end
  
  def test_base_directory
    ENV["OCRA_EXECUTABLE"] = '/tmp/tbr.exe'
    assert_equal('/tmp',@helper.base_directory)
    ENV["OCRA_EXECUTABLE"] = '\tmp\tbr.exe'
    assert_equal('/tmp',@helper.base_directory)
    ENV["OCRA_EXECUTABLE"] = ''
    assert_equal(Dir.pwd,@helper.base_directory)
    ENV["OCRA_EXECUTABLE"] = nil
    assert_equal(Dir.pwd,@helper.base_directory)
  end
  
  def test_services_path
    ENV["OCRA_EXECUTABLE"] = '/tmp/tbr.exe'
    assert_equal('/tmp/config/services.csv',@helper.services_path)
  end
  
  def test_config_path
    ENV["OCRA_EXECUTABLE"] = '/tmp/tbr.exe'
    assert_equal('/tmp/config/config.yaml',@helper.config_path)
  end
  
  def test_bill_path
    root = "#{Dir.pwd}/test"
    ENV["OCRA_EXECUTABLE"] = "#{root}/tbr.exe"
    assert_equal("./test/data/latest.csv",@helper.bill_path)
  end
  
  def test_initialise_config
    flunk 'TODO: test_initialise_config'
  end
  
  def test_import_services_file
    flunk 'TODO: test_import_services_file'
  end
  
  def test_dialogs
    if @@test_dialogs
      @helper.do_info(nil,'Test message')
      @helper.do_error(nil,'Test message')
      @helper.do_yn(nil,'Test message')
      @helper.do_log_review(nil,'Review log file',LOGFILE)
      @helper.do_config_review(nil,'Review config file',SERVICES)
      @helper.do_about(nil)
    end
  end
end
