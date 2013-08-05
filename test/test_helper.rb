require 'minitest/autorun'
require'fileutils'
 
require_relative '../app/helper'
require_relative '../app/configure'
require_relative '../app/groups'
require_relative '../app/services'

class TestHelper < MiniTest::Test 
  CONFIG_FILE = './test/data/test.yaml'
  
  def setup
    @helper = Helper.new
    @config = Configure.instance
    @config.file = CONFIG_FILE
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
  
  def test_fix_archive
    @config.data = './data'
    @config.archive = './test/archive'
    FileUtils.rm_rf(@config.archive)
    @helper.fix_directory_structure
    assert(@helper.check_directory_structure)
    FileUtils.rm_rf(@config.archive)
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
    FileUtils.touch('./test/data/latest.csv')
    assert_equal('./test/data/latest.csv',@helper.bill_path)
  end
  
  def test_initialise_config
		fname = './test/config.test'
		FileUtils.cp('./test/data/config.yaml',fname)
    @config.file = fname
    
    assert_equal('./DATA',@config.data)
    @helper.init_config('test',fname)	
    assert_equal('./data',@config.data)	
		assert(File.size(fname)== 0)
    
    FileUtils.rm_rf(fname)
    @config.file = CONFIG_FILE
  end
  
  def test_import_services
  	ENV["OCRA_EXECUTABLE"] = './tmp/tbr.exe' 
    config_path = './tmp/config'
    FileUtils.mkpath(config_path)  
    FileUtils.cp('./test/data/services.csv',config_path)
    
    assert_equal(14,count_services(config_path))
    @helper.import_services("./test/data/new.csv")
    assert_equal(3,count_services(config_path))
    
    FileUtils.rm_rf('./tmp')
  end
  
  def test_import_invalid_services
    assert_raises IOError do
      @helper.import_services("./test/data/missing.csv")
    end
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
  
  private
  
  def count_services(config_path)
  	services = Services.new
		groups = Groups.new
    ParseFiles.map_services(groups,services,"./tmp/config/services.csv")
    services.size
  end
end
